from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field, field_validator


class ServiceBase(BaseModel):
    name: str = Field(
        min_length=2,
        max_length=100,
        examples=["Polimento Completo"],
    )
    description: str | None = Field(
        default=None,
        max_length=1000,
        examples=["Polimento completo com cristalização."],
    )
    price: Decimal = Field(
        gt=0,
        decimal_places=2,
        examples=["150.00"],
    )
    duration_minutes: int = Field(
        gt=0,
        le=1440,
        examples=[120],
        description="Duração em minutos. Ex: 120 = 2h, 90 = 1h30.",
    )

    @field_validator("name")
    @classmethod
    def normalize_name(cls, v: str) -> str:
        return v.strip().title()

    @field_validator("price")
    @classmethod
    def round_price(cls, v: Decimal) -> Decimal:
        return round(v, 2)


class ServiceCreate(ServiceBase):
    pass


class ServiceUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=100)
    description: str | None = Field(default=None, max_length=1000)
    price: Decimal | None = Field(default=None, gt=0, decimal_places=2)
    duration_minutes: int | None = Field(default=None, gt=0, le=1440)

    @field_validator("name")
    @classmethod
    def normalize_name(cls, v: str | None) -> str | None:
        if v is not None:
            return v.strip().title()
        return v

    @field_validator("price")
    @classmethod
    def round_price(cls, v: Decimal | None) -> Decimal | None:
        if v is not None:
            return round(v, 2)
        return v


class ServiceResponse(ServiceBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    duration_display: str = Field(
        description="Duração formatada. Ex: '2h', '1h 30min', '45min'.",
    )

    @classmethod
    def from_orm_with_display(cls, service: object) -> "ServiceResponse":
        hours, minutes = divmod(service.duration_minutes, 60)
        if hours and minutes:
            duration_display = f"{hours}h {minutes}min"
        elif hours:
            duration_display = f"{hours}h"
        else:
            duration_display = f"{minutes}min"

        return cls(
            id=service.id,
            name=service.name,
            description=service.description,
            price=service.price,
            duration_minutes=service.duration_minutes,
            duration_display=duration_display,
        )


class ServiceListResponse(BaseModel):
    total: int
    items: list[ServiceResponse]