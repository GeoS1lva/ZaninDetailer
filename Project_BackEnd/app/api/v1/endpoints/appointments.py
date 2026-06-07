from typing import Annotated

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.auth import AuthenticatedUser
from app.infra.database import get_db
from app.schemas.appointment import (
    AppointmentCancel,
    AppointmentCreate,
    AppointmentReschedule,
    AppointmentResponse,
    AvailableSlotsResponse,
    ClientUpdate,
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
    slots, duration_minutes = await svc.get_available_slots(service_id, date)
    return AvailableSlotsResponse(
        date=date,
        service_id=service_id,
        duration_minutes=duration_minutes,
        slots=slots,
    )


@router.get(
    "/{appointment_id}",
    response_model=AppointmentResponse,
    summary="Consultar agendamento [admin]",
)
async def get_appointment(
    appointment_id: int, svc: Svc, _: AuthenticatedUser
) -> AppointmentResponse:
    appt = await svc.get_appointment(appointment_id)
    return AppointmentResponse.model_validate(appt)


@router.post(
    "/",
    response_model=AppointmentResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Criar agendamento",
)
async def create_appointment(
    data: AppointmentCreate, svc: Svc
) -> AppointmentResponse:
    appt = await svc.create_appointment(data)
    return AppointmentResponse.model_validate(appt)


@router.patch(
    "/{appointment_id}/reschedule",
    response_model=AppointmentResponse,
    summary="Reagendar atendimento [admin]",
    description="Altera data e horário do agendamento. Requer autenticação de administrador.",
)
async def reschedule_appointment(
    appointment_id: int, data: AppointmentReschedule, svc: Svc, _: AuthenticatedUser
) -> AppointmentResponse:
    appt = await svc.reschedule_appointment(appointment_id, data)
    return AppointmentResponse.model_validate(appt)


@router.post(
    "/{appointment_id}/cancel",
    response_model=AppointmentResponse,
    summary="Cancelar agendamento [admin]",
    description="Cancela o agendamento e libera o horário no Google Calendar. Requer autenticação de administrador.",
)
async def cancel_appointment(
    appointment_id: int, data: AppointmentCancel, svc: Svc, _: AuthenticatedUser
) -> AppointmentResponse:
    appt = await svc.cancel_appointment(appointment_id, data)
    return AppointmentResponse.model_validate(appt)


@router.patch(
    "/{appointment_id}/client",
    response_model=AppointmentResponse,
    summary="Atualizar dados do cliente [admin]",
    description="Atualiza os dados do cliente vinculado ao agendamento. Requer autenticação de administrador.",
)
async def update_appointment_client(
    appointment_id: int, data: ClientUpdate, svc: Svc, _: AuthenticatedUser
) -> AppointmentResponse:
    appt = await svc.update_appointment_client(appointment_id, data)
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