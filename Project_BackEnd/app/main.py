from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware # <-- 1. Importação adicionada

from app.api.v1.router import api_router
from app.infra.database import engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await engine.dispose()


def create_app() -> FastAPI:
    app = FastAPI(
        title="ZaninDetailer API",
        version="0.1.0",
        lifespan=lifespan,
    )

    origins = [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://127.0.0.1:52557"
    ]
    
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(api_router)
    return app


app = create_app()