from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.client import Client
from app.schemas.appointment import ClientCreate, ClientUpdate


class ClientRepository:
    def __init__(self, session: AsyncSession) -> None:
        self._session = session

    async def get_by_plate(self, plate: str) -> Client | None:
        result = await self._session.execute(
            select(Client).where(Client.license_plate == plate)
        )
        return result.scalar_one_or_none()

    async def create(self, data: ClientCreate) -> Client:
        client = Client(
            full_name=data.full_name,
            phone=data.phone,
            license_plate=data.license_plate,
            vehicle_brand_model=data.vehicle_brand_model,
        )
        self._session.add(client)
        await self._session.flush()
        await self._session.refresh(client)
        return client

    async def update(self, client: Client, data: ClientUpdate) -> Client:
        if data.full_name is not None:
            client.full_name = data.full_name
        if data.phone is not None:
            client.phone = data.phone
        if data.license_plate is not None:
            client.license_plate = data.license_plate
        if data.vehicle_brand_model is not None:
            client.vehicle_brand_model = data.vehicle_brand_model
        await self._session.flush()
        await self._session.refresh(client)
        return client

    async def get_or_create(self, data: ClientCreate) -> Client:
        client = await self.get_by_plate(data.license_plate)
        if client:
            client.full_name = data.full_name
            client.phone = data.phone
            if data.vehicle_brand_model:
                client.vehicle_brand_model = data.vehicle_brand_model
            await self._session.flush()
            return client
        return await self.create(data)