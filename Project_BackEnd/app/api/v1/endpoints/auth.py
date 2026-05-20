from fastapi import APIRouter, status

from app.dependencies.auth import AuthenticatedUser
from app.schemas.auth import (
    LoginRequest,
    LoginResponse,
    PasswordResetRequest,
    PasswordUpdateRequest,
    RefreshTokenRequest,
    UserCreate,
    UserListResponse,
    UserResponse,
    UserUpdate,
)
from app.services.auth_service import AuthService

router = APIRouter(tags=["Auth"])
svc = AuthService()

@router.post(
    "/auth/login",
    response_model=LoginResponse,
    summary="Login",
    description="Autentica com e-mail e senha. Retorna access_token e refresh_token.",
)
def login(data: LoginRequest) -> LoginResponse:
    return svc.login(data)


@router.post(
    "/auth/refresh",
    response_model=LoginResponse,
    summary="Renovar token",
    description="Gera um novo access_token a partir do refresh_token.",
)
def refresh_token(data: RefreshTokenRequest) -> LoginResponse:
    return svc.refresh_token(data.refresh_token)


@router.post(
    "/auth/password-reset",
    summary="Solicitar reset de senha",
    description="Envia e-mail com link de redefinição de senha.",
)
def request_password_reset(data: PasswordResetRequest) -> dict:
    return svc.request_password_reset(data)


@router.post(
    "/auth/password-update",
    summary="Redefinir senha",
    description="Atualiza a senha usando o token recebido no e-mail de reset.",
)
def update_password(data: PasswordUpdateRequest) -> dict:
    return svc.update_password(data)


@router.get(
    "/admin/users",
    response_model=UserListResponse,
    summary="Listar usuários",
)
def list_users(current_user: AuthenticatedUser) -> UserListResponse:
    return svc.list_users()


@router.get(
    "/admin/users/me",
    response_model=UserResponse,
    summary="Meu perfil",
)
def get_me(current_user: AuthenticatedUser) -> UserResponse:
    return current_user


@router.get(
    "/admin/users/{user_id}",
    response_model=UserResponse,
    summary="Buscar usuário por ID",
)
def get_user(user_id: str, current_user: AuthenticatedUser) -> UserResponse:
    return svc.get_user(user_id)


@router.post(
    "/admin/users",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Criar usuário admin",
)
def create_user(data: UserCreate, current_user: AuthenticatedUser) -> UserResponse:
    return svc.create_user(data)


@router.patch(
    "/admin/users/{user_id}",
    response_model=UserResponse,
    summary="Atualizar usuário",
)
def update_user(user_id: str, data: UserUpdate, current_user: AuthenticatedUser) -> UserResponse:
    return svc.update_user(user_id, data)


@router.delete(
    "/admin/users/{user_id}",
    summary="Remover usuário",
)
def delete_user(user_id: str, current_user: AuthenticatedUser) -> dict:
    return svc.delete_user(user_id)