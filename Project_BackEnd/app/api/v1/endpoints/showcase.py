from typing import Annotated

from fastapi import APIRouter, Depends, File, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.auth import AuthenticatedUser
from app.infra.database import get_db
from app.schemas.showcase import ShowcaseListResponse, ShowcaseResponse
from app.services.showcase_service import ShowcaseService

router = APIRouter(prefix="/showcases", tags=["Showcases"])

DbSession = Annotated[AsyncSession, Depends(get_db)]


def get_svc(session: DbSession) -> ShowcaseService:
    return ShowcaseService(session)


Svc = Annotated[ShowcaseService, Depends(get_svc)]


@router.get("/", response_model=ShowcaseListResponse, summary="Listar vitrines")
async def list_showcases(svc: Svc) -> ShowcaseListResponse:
    items, total = await svc.list_showcases()
    return ShowcaseListResponse(total=total, items=items)


@router.get("/{showcase_id}", response_model=ShowcaseResponse, summary="Buscar vitrine [admin]")
async def get_showcase(showcase_id: int, svc: Svc, _: AuthenticatedUser) -> ShowcaseResponse:
    return await svc.get_or_404(showcase_id)


@router.post(
    "/",
    response_model=ShowcaseResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Criar vitrine [admin]",
    description=f"Cria uma nova vitrine com imagem. Máximo de 5 vitrines permitidas.",
)
async def create_showcase(
    svc: Svc,
    _: AuthenticatedUser,
    image: Annotated[UploadFile, File()],
) -> ShowcaseResponse:
    return await svc.create_showcase(image)


@router.patch(
    "/{showcase_id}",
    response_model=ShowcaseResponse,
    summary="Atualizar vitrine [admin]",
    description="Substitui a imagem da vitrine. A imagem anterior é removida do storage.",
)
async def update_showcase(
    showcase_id: int,
    svc: Svc,
    _: AuthenticatedUser,
    image: Annotated[UploadFile, File()],
) -> ShowcaseResponse:
    return await svc.update_showcase(showcase_id, image)


@router.delete(
    "/{showcase_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Remover vitrine [admin]",
    description="Remove a vitrine e apaga a imagem do storage.",
)
async def delete_showcase(
    showcase_id: int,
    svc: Svc,
    _: AuthenticatedUser,
) -> None:
    await svc.delete_showcase(showcase_id)
