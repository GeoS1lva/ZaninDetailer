from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.showcase import Showcase


class ShowcaseRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def count(self) -> int:
        result = await self._session.execute(
            select(func.count()).select_from(Showcase)
        )
        return result.scalar_one()

    async def get_by_id(self, showcase_id: int) -> Showcase | None:
        result = await self._session.execute(
            select(Showcase).where(Showcase.id == showcase_id)
        )
        return result.scalar_one_or_none()

    async def list_all(self) -> tuple[list[Showcase], int]:
        total = await self.count()
        result = await self._session.execute(
            select(Showcase).order_by(Showcase.created_at.desc())
        )
        return list(result.scalars().all()), total

    async def create(self, image_url: str) -> Showcase:
        showcase = Showcase(image_url=image_url)
        self._session.add(showcase)
        await self._session.flush()
        await self._session.refresh(showcase)
        return showcase

    async def update(self, showcase: Showcase, image_url: str) -> Showcase:
        showcase.image_url = image_url
        await self._session.flush()
        await self._session.refresh(showcase)
        return showcase

    async def delete(self, showcase: Showcase) -> None:
        await self._session.delete(showcase)
        await self._session.flush()
