from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.infra.supabase_client import get_supabase_client
from app.schemas.auth import UserResponse

_bearer = HTTPBearer(auto_error=True)


async def get_current_user(
    credentials: Annotated[HTTPAuthorizationCredentials, Depends(_bearer)],
) -> UserResponse:
    token = credentials.credentials
    try:
        supabase = get_supabase_client()
        response = supabase.auth.get_user(token)

        if not response or not response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token inválido ou expirado.",
                headers={"WWW-Authenticate": "Bearer"},
            )

        user = response.user
        full_name = (user.user_metadata or {}).get("full_name")

        return UserResponse(
            id=str(user.id),
            email=user.email,
            full_name=full_name,
            created_at=str(user.created_at) if user.created_at else None,
            last_sign_in_at=str(user.last_sign_in_at) if user.last_sign_in_at else None,
        )
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido ou expirado.",
            headers={"WWW-Authenticate": "Bearer"},
        )

AuthenticatedUser = Annotated[UserResponse, Depends(get_current_user)]