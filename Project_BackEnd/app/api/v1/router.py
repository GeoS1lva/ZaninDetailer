from fastapi import APIRouter

from app.api.v1.endpoints.services import router as services_router

api_router = APIRouter(prefix="/api/v1")

api_router.include_router(services_router)