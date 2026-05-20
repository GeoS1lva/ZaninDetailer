from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo

from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import settings
from app.infra.google_calendar import (
    create_calendar_event,
    delete_calendar_event,
    get_busy_slots,
    update_calendar_event,
)
from app.models.appointment import Appointment, AppointmentStatus
from app.repositories.appointment_repository import AppointmentRepository
from app.repositories.client_repository import ClientRepository
from app.repositories.service_repository import ServiceRepository
from app.schemas.appointment import (
    AppointmentCancel,
    AppointmentCreate,
    AppointmentReschedule,
    AvailableSlot,
)

TZ = ZoneInfo(settings.calendar_timezone)
PAUSE_MINUTES = 20


class AppointmentService:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session
        self._repo = AppointmentRepository(session)
        self._client_repo = ClientRepository(session)
        self._service_repo = ServiceRepository(session)

    async def get_available_slots(
        self, service_id: int, date_str: str
    ) -> list[AvailableSlot]:
        service = await self._service_repo.get_by_id(service_id)
        if not service:
            raise HTTPException(status_code=404, detail="Serviço não encontrado.")

        slot_duration = timedelta(minutes=service.duration_minutes + PAUSE_MINUTES)

        naive_start = datetime.strptime(date_str, "%Y-%m-%d").replace(
            hour=settings.business_hour_start, minute=0
        )
        naive_end = datetime.strptime(date_str, "%Y-%m-%d").replace(
            hour=settings.business_hour_end, minute=0
        )
        day_start = naive_start.replace(tzinfo=TZ)
        day_end = naive_end.replace(tzinfo=TZ)

        if day_end <= datetime.now(tz=TZ):
            return []

        busy_google = get_busy_slots(day_start, day_end)
        busy_db = await self._repo.get_conflicting(day_start, day_end)

        busy_intervals: list[tuple[datetime, datetime]] = []

        for b in busy_google:
            b_start = datetime.fromisoformat(b["start"]).astimezone(TZ)
            b_end = datetime.fromisoformat(b["end"]).astimezone(TZ)
            busy_intervals.append((b_start, b_end))

        for appt in busy_db:
            busy_intervals.append((appt.scheduled_start, appt.scheduled_end))

        slots: list[AvailableSlot] = []
        cursor = max(day_start, datetime.now(tz=TZ).replace(second=0, microsecond=0))

        if cursor.minute % 30 != 0:
            extra = 30 - (cursor.minute % 30)
            cursor += timedelta(minutes=extra)
        cursor = cursor.replace(second=0, microsecond=0)

        while cursor + slot_duration <= day_end:
            candidate_end = cursor + slot_duration

            conflict = any(
                busy_start < candidate_end and busy_end > cursor
                for busy_start, busy_end in busy_intervals
            )

            if not conflict:
                slots.append(
                    AvailableSlot(
                        start=cursor,
                        end=cursor + timedelta(minutes=service.duration_minutes),
                        display=f"{cursor.strftime('%H:%M')} – {(cursor + timedelta(minutes=service.duration_minutes)).strftime('%H:%M')}",
                    )
                )

            cursor += timedelta(minutes=30)

        return slots

    async def create_appointment(self, data: AppointmentCreate) -> Appointment:
        service = await self._service_repo.get_by_id(data.service_id)
        if not service:
            raise HTTPException(status_code=404, detail="Serviço não encontrado.")

        scheduled_start = data.scheduled_start.astimezone(TZ)
        slot_duration = timedelta(minutes=service.duration_minutes + PAUSE_MINUTES)
        scheduled_end = scheduled_start + slot_duration

        self._validate_business_hours(scheduled_start, scheduled_end)

        conflicts = await self._repo.get_conflicting(scheduled_start, scheduled_end)
        if conflicts:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Horário indisponível. Escolha outro horário.",
            )

        client = await self._client_repo.get_or_create(data.client)

        appointment = await self._repo.create(
            client=client,
            service_id=service.id,
            scheduled_start=scheduled_start,
            scheduled_end=scheduled_end,
            total_price=service.price,
        )

        await self._repo.add_history(
            appointment,
            new_status=AppointmentStatus.PENDING,
            changed_by="client",
            reason="Agendamento criado.",
        )

        try:
            event_id = create_calendar_event(
                title=f"{service.name} — {client.full_name}",
                description=(
                    f"Serviço: {service.name}\n"
                    f"Cliente: {client.full_name}\n"
                    f"Telefone: {client.phone}\n"
                    f"Placa: {client.license_plate}\n"
                    f"Veículo: {client.vehicle_brand_model or 'Não informado'}\n"
                    f"Valor: R$ {service.price}"
                ),
                start=scheduled_start,
                end=scheduled_end,
            )
            appointment.google_event_id = event_id
        except Exception as exc:
            print(f"[WARN] Google Calendar falhou: {exc}")

        await self._repo.save(appointment)
        return await self._repo.get_by_id(appointment.id)

    async def reschedule_appointment(
        self, appointment_id: int, data: AppointmentReschedule
    ) -> Appointment:
        appointment = await self._get_or_404(appointment_id)
        self._validate_token(appointment, data.cancellation_token)
        self._validate_not_cancelled(appointment)

        service = appointment.service
        new_start = data.scheduled_start.astimezone(TZ)
        slot_duration = timedelta(minutes=service.duration_minutes + PAUSE_MINUTES)
        new_end = new_start + slot_duration

        self._validate_business_hours(new_start, new_end)

        conflicts = await self._repo.get_conflicting(
            new_start, new_end, exclude_id=appointment_id
        )
        if conflicts:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Horário indisponível. Escolha outro horário.",
            )

        old_start = appointment.scheduled_start

        appointment.scheduled_start = new_start
        appointment.scheduled_end = new_end

        await self._repo.add_history(
            appointment,
            previous_start=old_start,
            new_start=new_start,
            changed_by="client",
            reason="Reagendamento solicitado pelo cliente.",
        )

        if appointment.google_event_id:
            try:
                update_calendar_event(
                    appointment.google_event_id,
                    start=new_start,
                    end=new_end,
                )
            except Exception as exc:
                print(f"[WARN] Falha ao atualizar Google Calendar: {exc}")

        return await self._repo.get_by_id(appointment.id)


    async def cancel_appointment(
        self, appointment_id: int, data: AppointmentCancel
    ) -> Appointment:
        appointment = await self._get_or_404(appointment_id)
        self._validate_token(appointment, data.cancellation_token)
        self._validate_not_cancelled(appointment)

        old_status = appointment.status
        appointment.status = AppointmentStatus.CANCELLED

        await self._repo.add_history(
            appointment,
            previous_status=old_status,
            new_status=AppointmentStatus.CANCELLED,
            reason=data.reason or "Cancelado pelo cliente.",
            changed_by="client",
        )

        if appointment.google_event_id:
            try:
                delete_calendar_event(appointment.google_event_id)
                appointment.google_event_id = None
            except Exception as exc:
                print(f"[WARN] Falha ao remover evento do Google Calendar: {exc}")

        return await self._repo.get_by_id(appointment.id)

    async def get_appointment(self, appointment_id: int) -> Appointment:
        return await self._get_or_404(appointment_id)
    
    async def list_by_date(self, date_str: str) -> list[Appointment]:
        from zoneinfo import ZoneInfo
        from datetime import datetime, timedelta
        naive = datetime.strptime(date_str, "%Y-%m-%d")
        day_start = naive.replace(hour=0, minute=0, second=0, tzinfo=TZ)
        day_end = day_start + timedelta(days=1)
        return await self._repo.list_by_date_range(day_start, day_end)

    async def _get_or_404(self, appointment_id: int) -> Appointment:
        appt = await self._repo.get_by_id(appointment_id)
        if not appt:
            raise HTTPException(status_code=404, detail="Agendamento não encontrado.")
        return appt

    @staticmethod
    def _validate_token(appointment: Appointment, token: str) -> None:
        if appointment.cancellation_token != token:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Token inválido. Você não tem permissão para modificar este agendamento.",
            )

    @staticmethod
    def _validate_not_cancelled(appointment: Appointment) -> None:
        if appointment.status == AppointmentStatus.CANCELLED:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="Este agendamento já está cancelado.",
            )

    @staticmethod
    def _validate_business_hours(start: datetime, end: datetime) -> None:
        if start.hour < settings.business_hour_start or end.hour > settings.business_hour_end:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=(
                    f"Horário fora do expediente. "
                    f"Atendemos das {settings.business_hour_start:02d}h "
                    f"às {settings.business_hour_end:02d}h."
                ),
            )