from datetime import datetime
from decimal import Decimal
from zoneinfo import ZoneInfo

from pydantic import BaseModel, ConfigDict, Field, field_serializer, field_validator

BR_TZ = ZoneInfo("America/Sao_Paulo")

class ClientCreate(BaseModel):
    full_name: str = Field(min_length=3, max_length=150, examples=["João da Silva"])
    phone: str = Field(min_length=10, max_length=20, examples=["11999999999"])
    license_plate: str = Field(min_length=7, max_length=10, examples=["ABC1234"])
    vehicle_brand_model: str | None = Field(default=None, max_length=100, examples=["Chevrolet Onix"])

    @field_validator("license_plate")
    @classmethod
    def normalize_plate(cls, v: str) -> str:
        return v.strip().upper().replace("-", "").replace(" ", "")

    @field_validator("phone")
    @classmethod
    def normalize_phone(cls, v: str) -> str:
        digits = "".join(c for c in v if c.isdigit())
        if len(digits) < 10:
            raise ValueError("Telefone deve ter pelo menos 10 dígitos com DDD.")
        return digits


class ClientUpdate(BaseModel):
    full_name: str | None = Field(default=None, min_length=3, max_length=150)
    phone: str | None = Field(default=None, min_length=10, max_length=20)
    license_plate: str | None = Field(default=None, min_length=7, max_length=10)
    vehicle_brand_model: str | None = Field(default=None, max_length=100)

    @field_validator("license_plate")
    @classmethod
    def normalize_plate(cls, v: str | None) -> str | None:
        if v is not None:
            return v.strip().upper().replace("-", "").replace(" ", "")
        return v

    @field_validator("phone")
    @classmethod
    def normalize_phone(cls, v: str | None) -> str | None:
        if v is not None:
            digits = "".join(c for c in v if c.isdigit())
            if len(digits) < 10:
                raise ValueError("Telefone deve ter pelo menos 10 dígitos com DDD.")
            return digits
        return v


class ClientResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    full_name: str
    phone: str
    license_plate: str
    vehicle_brand_model: str | None

class AvailableSlot(BaseModel):
    start: datetime
    end: datetime
    display: str


class AvailableSlotsResponse(BaseModel):
    date: str
    service_id: int
    duration_minutes: int
    slots: list[AvailableSlot]

class AppointmentCreate(BaseModel):
    service_id: int = Field(gt=0)
    scheduled_start: datetime = Field(examples=["2025-06-10T09:00:00-03:00"])
    client: ClientCreate


class AppointmentReschedule(BaseModel):
    scheduled_start: datetime


class AppointmentCancel(BaseModel):
    reason: str | None = Field(default=None, max_length=500)


class AppointmentHistoryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    previous_status: str | None
    new_status: str | None
    previous_start: datetime | None
    new_start: datetime | None
    reason: str | None
    changed_by: str
    changed_at: datetime

    @field_serializer("changed_at", "previous_start", "new_start")
    def serialize_dt(self, v: datetime | None) -> str | None:
        if v is None:
            return None
        return v.astimezone(BR_TZ).isoformat()


class AppointmentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    service_id: int
    scheduled_start: datetime
    scheduled_end: datetime
    status: str
    total_price: Decimal
    client: ClientResponse
    history: list[AppointmentHistoryResponse] = []
    created_at: datetime
    updated_at: datetime

    @field_serializer("scheduled_start", "scheduled_end", "created_at", "updated_at")
    def serialize_dt(self, v: datetime | None) -> str | None:
        if v is None:
            return None
        return v.astimezone(BR_TZ).isoformat()


