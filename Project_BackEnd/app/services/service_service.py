from fastapi import HTTPException, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.cache import services_cache
from app.infra.supabase_storage import delete_image, upload_image
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

    async def list_services(self, offset: int, limit: int) -> tuple[list[Service], int]:
        key = f"list:{offset}:{limit}"
        cached = await services_cache.get(key)
        if cached is not None:
            return cached
        result = await self._repo.list_all(offset=offset, limit=limit)
        await services_cache.set(key, result)
        return result

    async def create_service(self, data: ServiceCreate, image: UploadFile | None = None) -> Service:
        existing = await self._repo.get_by_name(data.name)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Já existe um serviço com o nome '{data.name}'.",
            )
        image_url = await upload_image(image) if image else None
        service = await self._repo.create(data, image_url=image_url)
        await services_cache.invalidate("list:")
        return service

    async def update_service(
        self, service_id: int, data: ServiceUpdate, image: UploadFile | None = None
    ) -> Service:
        service = await self.get_or_404(service_id)

        if data.name and data.name != service.name:
            existing = await self._repo.get_by_name(data.name)
            if existing:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail=f"Já existe um serviço com o nome '{data.name}'.",
                )

        image_url = None
        if image:
            if service.image_url:
                await delete_image(service.image_url)
            image_url = await upload_image(image)

        service = await self._repo.update(service, data, image_url=image_url)
        await services_cache.invalidate("list:")
        return service

    async def delete_service(self, service_id: int) -> None:
        service = await self.get_or_404(service_id)
        if service.image_url:
            await delete_image(service.image_url)
        await self._repo.delete(service)
        await services_cache.invalidate("list:")
