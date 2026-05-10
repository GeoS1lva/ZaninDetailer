from contextlib import asynccontextmanager

from fastapi import FastAPI

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
    return app


app = create_app()