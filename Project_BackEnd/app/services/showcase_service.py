from fastapi import HTTPException, UploadFile, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.cache import showcases_cache
from app.infra.supabase_storage import delete_image, upload_image
from app.models.showcase import Showcase
from app.repositories.showcase_repository import ShowcaseRepository

MAX_SHOWCASES = 5


class ShowcaseService:
    def __init__(self, session: AsyncSession) -> None:
        self._repo = ShowcaseRepository(session)

    async def list_showcases(self) -> tuple[list[Showcase], int]:
        cached = await showcases_cache.get("list")
        if cached is not None:
            return cached
        result = await self._repo.list_all()
        await showcases_cache.set("list", result)
        return result

    async def get_or_404(self, showcase_id: int) -> Showcase:
        showcase = await self._repo.get_by_id(showcase_id)
        if not showcase:
            raise HTTPException(status_code=404, detail="Vitrine não encontrada.")
        return showcase

    async def create_showcase(self, image: UploadFile) -> Showcase:
        count = await self._repo.count()
        if count >= MAX_SHOWCASES:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Limite de {MAX_SHOWCASES} vitrines atingido. Atualize uma vitrine existente.",
            )
        image_url = await upload_image(image)
        showcase = await self._repo.create(image_url)
        await showcases_cache.invalidate("list")
        return showcase

    async def update_showcase(self, showcase_id: int, image: UploadFile) -> Showcase:
        showcase = await self.get_or_404(showcase_id)
        await delete_image(showcase.image_url)
        image_url = await upload_image(image)
        showcase = await self._repo.update(showcase, image_url)
        await showcases_cache.invalidate("list")
        return showcase

    async def delete_showcase(self, showcase_id: int) -> None:
        showcase = await self.get_or_404(showcase_id)
        await delete_image(showcase.image_url)
        await self._repo.delete(showcase)
        await showcases_cache.invalidate("list")
