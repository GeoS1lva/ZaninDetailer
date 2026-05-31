from decimal import Decimal
from typing import Annotated

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.auth import AuthenticatedUser
from app.infra.database import get_db
from app.schemas.service import (
    ServiceCreate,
    ServiceListResponse,
    ServiceResponse,
    ServiceUpdate,
)
from app.services.service_service import ServiceService

router = APIRouter(prefix="/services", tags=["Services"])

DbSession = Annotated[AsyncSession, Depends(get_db)]


def get_service_service(session: DbSession) -> ServiceService:
    return ServiceService(session)


ServiceDep = Annotated[ServiceService, Depends(get_service_service)]


@router.get("/", response_model=ServiceListResponse, summary="Listar serviços")
async def list_services(
    svc: ServiceDep,
    offset: Annotated[int, Query(ge=0)] = 0,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
) -> ServiceListResponse:
    items, total = await svc.list_services(offset=offset, limit=limit)
    return ServiceListResponse(
        total=total,
        items=[ServiceResponse.from_orm_with_display(s) for s in items],
    )


@router.get("/{service_id}", response_model=ServiceResponse, summary="Buscar serviço por ID")
async def get_service(service_id: int, svc: ServiceDep) -> ServiceResponse:
    service = await svc.get_or_404(service_id)
    return ServiceResponse.from_orm_with_display(service)


@router.post("/", response_model=ServiceResponse, status_code=201, summary="Criar serviço [admin]")
async def create_service(
    svc: ServiceDep,
    _: AuthenticatedUser,
    name: Annotated[str, Form()],
    price: Annotated[Decimal, Form()],
    duration_minutes: Annotated[int, Form()],
    description: Annotated[str | None, Form()] = None,
    image: Annotated[UploadFile | None, File()] = None,
) -> ServiceResponse:
    data = ServiceCreate(name=name, price=price, duration_minutes=duration_minutes, description=description)
    service = await svc.create_service(data, image)
    return ServiceResponse.from_orm_with_display(service)


@router.patch("/{service_id}", response_model=ServiceResponse, summary="Atualizar serviço [admin]")
async def update_service(
    service_id: int,
    svc: ServiceDep,
    _: AuthenticatedUser,
    name: Annotated[str | None, Form()] = None,
    price: Annotated[Decimal | None, Form()] = None,
    duration_minutes: Annotated[int | None, Form()] = None,
    description: Annotated[str | None, Form()] = None,
    image: Annotated[UploadFile | None, File()] = None,
) -> ServiceResponse:
    data = ServiceUpdate(name=name, price=price, duration_minutes=duration_minutes, description=description)
    service = await svc.update_service(service_id, data, image)
    return ServiceResponse.from_orm_with_display(service)


@router.delete(
    "/{service_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Remover serviço [admin]",
)
async def delete_service(
    service_id: int,
    svc: ServiceDep,
    _: AuthenticatedUser,
) -> None:
    await svc.delete_service(service_id)