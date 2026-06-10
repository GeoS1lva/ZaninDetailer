from pydantic import computed_field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    postgres_user: str
    postgres_password: str
    postgres_db: str
    postgres_host: str = "localhost"
    postgres_port: int = 5432

    app_env: str = "development"
    secret_key: str
    debug: bool = False

    google_calendar_id: str
    calendar_timezone: str = "America/Sao_Paulo"

    business_hour_start: int = 8
    business_hour_end: int = 18

    supabase_url: str
    supabase_anon_key: str
    supabase_service_key: str

    @computed_field
    @property
    def database_url(self) -> str:
        return (
            f"postgresql+asyncpg://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )


settings = Settings()