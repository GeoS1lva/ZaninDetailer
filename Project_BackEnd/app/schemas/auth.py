from pydantic import BaseModel, EmailStr, Field

class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6)


class LoginResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user_id: str
    email: str


class RefreshTokenRequest(BaseModel):
    refresh_token: str


class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordUpdateRequest(BaseModel):
    access_token: str
    new_password: str = Field(min_length=6)

class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(min_length=6)
    full_name: str = Field(min_length=2, max_length=150)


class UserUpdate(BaseModel):
    full_name: str | None = Field(default=None, min_length=2, max_length=150)
    password: str | None = Field(default=None, min_length=6)


class UserResponse(BaseModel):
    id: str
    email: str
    full_name: str | None = None
    created_at: str | None = None
    last_sign_in_at: str | None = None


class UserListResponse(BaseModel):
    total: int
    users: list[UserResponse]