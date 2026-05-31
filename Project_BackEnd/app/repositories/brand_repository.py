from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.brand import Brand
from app.schemas.brand import BrandCreate, BrandUpdate


class BrandRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get_by_id(self, brand_id: int) -> Brand | None:
        result = await self._session.execute(select(Brand).where(Brand.id == brand_id))
        return result.scalar_one_or_none()

    async def get_by_name(self, name: str) -> Brand | None:
        result = await self._session.execute(select(Brand).where(Brand.name == name))
        return result.scalar_one_or_none()

    async def list_all(self, offset: int = 0, limit: int = 20) -> tuple[list[Brand], int]:
        total = (await self._session.execute(select(func.count()).select_from(Brand))).scalar_one()
        result = await self._session.execute(
            select(Brand).order_by(Brand.name).offset(offset).limit(limit)
        )
        return list(result.scalars().all()), total

    async def create(self, data: BrandCreate, image_url: str | None = None) -> Brand:
        brand = Brand(name=data.name, image_url=image_url)
        self._session.add(brand)
        await self._session.flush()
        await self._session.refresh(brand)
        return brand

    async def update(self, brand: Brand, data: BrandUpdate, image_url: str | None = None) -> Brand:
        if data.name is not None:
            brand.name = data.name
        if image_url is not None:
            brand.image_url = image_url
        await self._session.flush()
        await self._session.refresh(brand)
        return brand

    async def delete(self, brand: Brand) -> None:
        await self._session.delete(brand)
        await self._session.flush()