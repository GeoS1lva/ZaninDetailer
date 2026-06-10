from fastapi import APIRouter

from app.api.v1.endpoints.services import router as services_router
from app.api.v1.endpoints.appointments import router as appointments_router
from app.api.v1.endpoints.auth import router as auth_router
from app.api.v1.endpoints.brands import router as brands_router
from app.api.v1.endpoints.showcase import router as showcase_router

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth_router)
api_router.include_router(services_router)
api_router.include_router(appointments_router)
api_router.include_router(brands_router)
api_router.include_router(showcase_router)