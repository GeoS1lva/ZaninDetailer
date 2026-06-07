from typing import Annotated

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies.auth import AuthenticatedUser
from app.infra.database import get_db
from app.schemas.brand import BrandCreate, BrandListResponse, BrandResponse, BrandUpdate
from app.services.brand_service import BrandService

router = APIRouter(prefix="/brands", tags=["Brands"])

DbSession = Annotated[AsyncSession, Depends(get_db)]


def get_svc(session: DbSession) -> BrandService:
    return BrandService(session)


Svc = Annotated[BrandService, Depends(get_svc)]


@router.get("/", response_model=BrandListResponse, summary="Listar marcas")
async def list_brands(
    svc: Svc,
    offset: Annotated[int, Query(ge=0)] = 0,
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
) -> BrandListResponse:
    items, total = await svc.list_brands(offset=offset, limit=limit)
    return BrandListResponse(total=total, items=items)


@router.get("/{brand_id}", response_model=BrandResponse, summary="Buscar marca [admin]")
async def get_brand(brand_id: int, svc: Svc, _: AuthenticatedUser) -> BrandResponse:
    return await svc.get_or_404(brand_id)


@router.post(
    "/",
    response_model=BrandResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Criar marca [admin]",
)
async def create_brand(
    svc: Svc,
    _: AuthenticatedUser,
    name: Annotated[str, Form()],
    image: Annotated[UploadFile | None, File()] = None,
) -> BrandResponse:
    data = BrandCreate(name=name)
    return await svc.create_brand(data, image)


@router.patch("/{brand_id}", response_model=BrandResponse, summary="Atualizar marca [admin]")
async def update_brand(
    brand_id: int,
    svc: Svc,
    _: AuthenticatedUser,
    name: Annotated[str | None, Form()] = None,
    image: Annotated[UploadFile | None, File()] = None,
) -> BrandResponse:
    data = BrandUpdate(name=name)
    return await svc.update_brand(brand_id, data, image)


@router.delete("/{brand_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Remover marca [admin]")
async def delete_brand(brand_id: int, svc: Svc, _: AuthenticatedUser) -> None:
    await svc.delete_brand(brand_id)