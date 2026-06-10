from fastapi import HTTPException, status

from app.infra.supabase_client import get_supabase_admin, get_supabase_client
from app.schemas.auth import (
    LoginRequest,
    LoginResponse,
    PasswordResetRequest,
    PasswordUpdateRequest,
    UserCreate,
    UserListResponse,
    UserResponse,
    UserUpdate,
)


class AuthService:

    def login(self, data: LoginRequest) -> LoginResponse:
        try:
            supabase = get_supabase_client()
            response = supabase.auth.sign_in_with_password(
                {"email": data.email, "password": data.password}
            )
            session = response.session
            user = response.user

            if not session or not user:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="E-mail ou senha incorretos.",
                )

            return LoginResponse(
                access_token=session.access_token,
                refresh_token=session.refresh_token,
                token_type="bearer",
                user_id=str(user.id),
                email=user.email,
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="E-mail ou senha incorretos.",
            ) from e



    def refresh_token(self, refresh_token: str) -> LoginResponse:
        try:
            supabase = get_supabase_client()
            response = supabase.auth.refresh_session(refresh_token)
            session = response.session
            user = response.user

            if not session:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Refresh token inválido ou expirado.",
                )

            return LoginResponse(
                access_token=session.access_token,
                refresh_token=session.refresh_token,
                token_type="bearer",
                user_id=str(user.id),
                email=user.email,
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh token inválido ou expirado.",
            ) from e
        

    def request_password_reset(self, data: PasswordResetRequest) -> dict:
        try:
            supabase = get_supabase_client()
            supabase.auth.reset_password_email(data.email)
            return {"message": "Se o e-mail estiver cadastrado, você receberá as instruções em breve."}
        except Exception as e:
            return {"message": "Se o e-mail estiver cadastrado, você receberá as instruções em breve."}

    def update_password(self, data: PasswordUpdateRequest) -> dict:
        try:
            supabase = get_supabase_client()
            user_response = supabase.auth.get_user(data.access_token)
            if not user_response or not user_response.user:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Token inválido ou expirado. Solicite um novo reset de senha.",
                )

            user_id = str(user_response.user.id)

            admin = get_supabase_admin()
            admin.auth.admin.update_user_by_id(user_id, {"password": data.new_password})
            return {"message": "Senha atualizada com sucesso."}
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Token inválido ou expirado. Solicite um novo reset de senha.",
            ) from e



    def list_users(self) -> UserListResponse:
        try:
            admin = get_supabase_admin()
            response = admin.auth.admin.list_users()
            users = [
                UserResponse(
                    id=str(u.id),
                    email=u.email,
                    full_name=(u.user_metadata or {}).get("full_name"),
                    created_at=str(u.created_at) if u.created_at else None,
                    last_sign_in_at=str(u.last_sign_in_at) if u.last_sign_in_at else None,
                )
                for u in response
            ]
            return UserListResponse(total=len(users), users=users)
        except Exception as e:
            raise HTTPException(status_code=500, detail="Erro ao listar usuários.") from e

    def get_user(self, user_id: str) -> UserResponse:
        try:
            admin = get_supabase_admin()
            u = admin.auth.admin.get_user_by_id(user_id).user
            if not u:
                raise HTTPException(status_code=404, detail="Usuário não encontrado.")
            return UserResponse(
                id=str(u.id),
                email=u.email,
                full_name=(u.user_metadata or {}).get("full_name"),
                created_at=str(u.created_at) if u.created_at else None,
                last_sign_in_at=str(u.last_sign_in_at) if u.last_sign_in_at else None,
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail="Erro ao buscar usuário.") from e

    def create_user(self, data: UserCreate) -> UserResponse:
        try:
            admin = get_supabase_admin()
            response = admin.auth.admin.create_user({
                "email": data.email,
                "password": data.password,
                "user_metadata": {"full_name": data.full_name},
                "email_confirm": True,
            })
            u = response.user
            return UserResponse(
                id=str(u.id),
                email=u.email,
                full_name=(u.user_metadata or {}).get("full_name"),
                created_at=str(u.created_at) if u.created_at else None,
            )
        except Exception as e:
            if "already registered" in str(e).lower() or "already been registered" in str(e).lower():
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Este e-mail já está cadastrado.",
                )
            raise HTTPException(status_code=500, detail="Erro ao criar usuário.") from e

    def update_user(self, user_id: str, data: UserUpdate) -> UserResponse:
        try:
            admin = get_supabase_admin()
            payload: dict = {}
            if data.full_name is not None:
                payload["user_metadata"] = {"full_name": data.full_name}
            if data.password is not None:
                payload["password"] = data.password

            if not payload:
                return self.get_user(user_id)

            response = admin.auth.admin.update_user_by_id(user_id, payload)
            u = response.user
            return UserResponse(
                id=str(u.id),
                email=u.email,
                full_name=(u.user_metadata or {}).get("full_name"),
                created_at=str(u.created_at) if u.created_at else None,
            )
        except HTTPException:
            raise
        except Exception as e:
            raise HTTPException(status_code=500, detail="Erro ao atualizar usuário.") from e

    def delete_user(self, user_id: str) -> dict:
        try:
            admin = get_supabase_admin()
            admin.auth.admin.delete_user(user_id)
            return {"message": "Usuário removido com sucesso."}
        except Exception as e:
            raise HTTPException(status_code=500, detail="Erro ao remover usuário.") from e