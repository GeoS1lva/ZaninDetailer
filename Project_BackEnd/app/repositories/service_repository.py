from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.service import Service
from app.schemas.service import ServiceCreate, ServiceUpdate


class ServiceRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get_by_id(self, service_id: int) -> Service | None:
        result = await self._session.execute(
            select(Service).where(Service.id == service_id)
        )
        return result.scalar_one_or_none()

    async def get_by_name(self, name: str) -> Service | None:
        result = await self._session.execute(
            select(Service).where(Service.name == name)
        )
        return result.scalar_one_or_none()

    async def list_all(
        self,
        offset: int = 0,
        limit: int = 20,
    ) -> tuple[list[Service], int]:
        total_result = await self._session.execute(
            select(func.count()).select_from(Service)
        )
        total = total_result.scalar_one()

        result = await self._session.execute(
            select(Service)
            .order_by(Service.name)
            .offset(offset)
            .limit(limit)
        )
        items = list(result.scalars().all())
        return items, total

    async def create(self, data: ServiceCreate) -> Service:
        service = Service(
            name=data.name,
            description=data.description,
            price=data.price,
            duration_minutes=data.duration_minutes,
        )
        self._session.add(service)
        await self._session.flush()
        await self._session.refresh(service)
        return service

    async def update(self, service: Service, data: ServiceUpdate) -> Service:
        update_data = data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(service, field, value)
        await self._session.flush()
        await self._session.refresh(service)
        return service

    async def delete(self, service: Service) -> None:
        await self._session.delete(service)
        await self._session.flush()