from fastapi import HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.service import Service
from app.repositories.service_repository import ServiceRepository
from app.schemas.service import ServiceCreate, ServiceUpdate


class ServiceService:
    def __init__(self, session: AsyncSession) -> None:
        self._repo = ServiceRepository(session)

    async def get_or_404(self, service_id: int) -> Service:
        service = await self._repo.get_by_id(service_id)
        if not service:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Serviço com id {service_id} não encontrado.",
            )
        return service

    async def list_services(
        self, offset: int, limit: int
    ) -> tuple[list[Service], int]:
        return await self._repo.list_all(offset=offset, limit=limit)

    async def create_service(self, data: ServiceCreate) -> Service:
        existing = await self._repo.get_by_name(data.name)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Já existe um serviço com o nome '{data.name}'.",
            )
        return await self._repo.create(data)

    async def update_service(
        self, service_id: int, data: ServiceUpdate
    ) -> Service:
        service = await self.get_or_404(service_id)

        if data.name and data.name != service.name:
            existing = await self._repo.get_by_name(data.name)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Já existe um serviço com o nome '{data.name}'.",
                )

        return await self._repo.update(service, data)

    async def delete_service(self, service_id: int) -> None:
        service = await self.get_or_404(service_id)
        await self._repo.delete(service)