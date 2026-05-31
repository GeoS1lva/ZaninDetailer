from fastapi import HTTPException, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.infra.supabase_storage import delete_image, upload_image
from app.models.brand import Brand
from app.repositories.brand_repository import BrandRepository
from app.schemas.brand import BrandCreate, BrandUpdate


class BrandService:
    def __init__(self, session: AsyncSession) -> None:
        self._repo = BrandRepository(session)

    async def list_brands(self, offset: int, limit: int) -> tuple[list[Brand], int]:
        return await self._repo.list_all(offset=offset, limit=limit)

    async def get_or_404(self, brand_id: int) -> Brand:
        brand = await self._repo.get_by_id(brand_id)
        if not brand:
            raise HTTPException(status_code=404, detail="Marca não encontrada.")
        return brand

    async def create_brand(self, data: BrandCreate, image: UploadFile | None) -> Brand:
        existing = await self._repo.get_by_name(data.name)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Já existe uma marca com o nome '{data.name}'.",
            )
        image_url = upload_image(image) if image else None
        return await self._repo.create(data, image_url=image_url)

    async def update_brand(
        self, brand_id: int, data: BrandUpdate, image: UploadFile | None
    ) -> Brand:
        brand = await self.get_or_404(brand_id)

        if data.name and data.name != brand.name:
            existing = await self._repo.get_by_name(data.name)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Já existe uma marca com o nome '{data.name}'.",
                )

        image_url = None
        if image:
            if brand.image_url:
                delete_image(brand.image_url)
            image_url = upload_image(image)

        return await self._repo.update(brand, data, image_url=image_url)

    async def delete_brand(self, brand_id: int) -> None:
        brand = await self.get_or_404(brand_id)
        if brand.image_url:
            delete_image(brand.image_url)
        await self._repo.delete(brand)