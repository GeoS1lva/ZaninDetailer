import uuid
from fastapi import HTTPException, UploadFile

from app.infra.supabase_client import get_supabase_admin

BUCKET = "bucket-imagens-zanindetailer"
ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_SIZE_MB = 5


def upload_image(file: UploadFile) -> str:
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=400,
            detail="Formato inválido. Use JPEG, PNG ou WebP.",
        )

    content = file.file.read()

    if len(content) > MAX_SIZE_MB * 1024 * 1024:
        raise HTTPException(
            status_code=400,
            detail=f"Imagem muito grande. Máximo {MAX_SIZE_MB}MB.",
        )

    extension = file.content_type.split("/")[-1].replace("jpeg", "jpg")
    filename = f"{uuid.uuid4()}.{extension}"

    admin = get_supabase_admin()
    admin.storage.from_(BUCKET).upload(
        path=filename,
        file=content,
        file_options={"content-type": file.content_type, "upsert": "false"},
    )

    public_url = admin.storage.from_(BUCKET).get_public_url(filename)
    return public_url


def delete_image(url: str) -> None:
    try:
        filename = url.split(f"{BUCKET}/")[-1]
        admin = get_supabase_admin()
        admin.storage.from_(BUCKET).remove([filename])
    except Exception:
        pass