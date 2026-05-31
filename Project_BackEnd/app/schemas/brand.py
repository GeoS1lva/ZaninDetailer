from pydantic import BaseModel, ConfigDict, Field


class BrandCreate(BaseModel):
    name: str = Field(min_length=2, max_length=100, examples=["Meguiar's"])


class BrandUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=100)


class BrandResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    image_url: str | None


class BrandListResponse(BaseModel):
    total: int
    items: list[BrandResponse]