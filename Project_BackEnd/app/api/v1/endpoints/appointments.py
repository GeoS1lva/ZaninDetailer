from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.auth import AuthenticatedUser
from app.infra.database import get_db
from app.schemas.appointment import (
    AppointmentCancel,
    AppointmentCreate,
    AppointmentCreatedResponse,
    AppointmentReschedule,
    AppointmentResponse,
    AvailableSlotsResponse,
)
from app.services.appointment_service import AppointmentService

router = APIRouter(prefix="/appointments", tags=["Appointments"])

DbSession = Annotated[AsyncSession, Depends(get_db)]


def get_svc(session: DbSession) -> AppointmentService:
    return AppointmentService(session)


Svc = Annotated[AppointmentService, Depends(get_svc)]


@router.get(
    "/available-slots",
    response_model=AvailableSlotsResponse,
    summary="Horários disponíveis",
    description=(
        "Retorna os horários livres para um serviço em uma data. "
        "Considera o Google Calendar e agendamentos existentes. "
        "Cada slot já inclui a pausa de 20 minutos entre atendimentos."
    ),
)
async def available_slots(
    svc: Svc,
    service_id: Annotated[int, Query(gt=0)],
    date: Annotated[str, Query(pattern=r"^\d{4}-\d{2}-\d{2}$", examples=["2025-06-10"])],
) -> AvailableSlotsResponse:
    from app.repositories.service_repository import ServiceRepository
    from app.infra.database import AsyncSessionLocal

    async with AsyncSessionLocal() as s:
        repo = ServiceRepository(s)
        service = await repo.get_by_id(service_id)

    slots = await svc.get_available_slots(service_id, date)
    return AvailableSlotsResponse(
        date=date,
        service_id=service_id,
        duration_minutes=service.duration_minutes if service else 0,
        slots=slots,
    )


@router.get(
    "/{appointment_id}",
    response_model=AppointmentResponse,
    summary="Consultar agendamento",
)
async def get_appointment(appointment_id: int, svc: Svc) -> AppointmentResponse:
    appt = await svc.get_appointment(appointment_id)
    return AppointmentResponse.model_validate(appt)


@router.post(
    "/",
    response_model=AppointmentCreatedResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Criar agendamento",
    description=(
        "Cria um novo agendamento. "
        "Retorna o `cancellation_token` — guarde-o, pois é necessário para cancelar ou reagendar."
    ),
)
async def create_appointment(
    data: AppointmentCreate, svc: Svc
) -> AppointmentCreatedResponse:
    appt = await svc.create_appointment(data)
    response = AppointmentCreatedResponse.model_validate(appt)
    response.cancellation_token = appt.cancellation_token
    return response


@router.patch(
    "/{appointment_id}/reschedule",
    response_model=AppointmentResponse,
    summary="Reagendar atendimento",
    description="Altera data e horário do agendamento. Requer o cancellation_token.",
)
async def reschedule_appointment(
    appointment_id: int, data: AppointmentReschedule, svc: Svc
) -> AppointmentResponse:
    appt = await svc.reschedule_appointment(appointment_id, data)
    return AppointmentResponse.model_validate(appt)


@router.post(
    "/{appointment_id}/cancel",
    response_model=AppointmentResponse,
    summary="Cancelar agendamento",
    description=(
        "Cancela o agendamento e libera o horário no Google Calendar. "
        "Requer o cancellation_token recebido na criação."
    ),
)
async def cancel_appointment(
    appointment_id: int, data: AppointmentCancel, svc: Svc
) -> AppointmentResponse:
    appt = await svc.cancel_appointment(appointment_id, data)
    return AppointmentResponse.model_validate(appt)

@router.get(
    "/",
    response_model=list[AppointmentResponse],
    summary="Listar agendamentos por data [admin]",
)
async def list_appointments_by_date(
    svc: Svc,
    _: AuthenticatedUser,
    date: Annotated[str, Query(pattern=r"^\d{4}-\d{2}-\d{2}$", examples=["2025-06-10"])],
) -> list[AppointmentResponse]:
    appointments = await svc.list_by_date(date)
    return [AppointmentResponse.model_validate(a) for a in appointments]