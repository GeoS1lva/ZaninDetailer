from datetime import datetime

from pydantic import BaseModel, ConfigDict


class ShowcaseResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    image_url: str
    created_at: datetime
    updated_at: datetime


class ShowcaseListResponse(BaseModel):
    total: int
    items: list[ShowcaseResponse]
