import uuid
from fastapi import HTTPException, UploadFile

from app.infra.supabase_client import get_supabase_admin

BUCKET = "bucket-imagens-zanindetailer"
ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_SIZE_MB = 5

_MAGIC_BYTES: dict[str, list[bytes]] = {
    "image/jpeg": [b"\xff\xd8\xff"],
    "image/png":  [b"\x89PNG\r\n\x1a\n"],
    "image/webp": [b"RIFF"],  # verificado junto com offset 8 abaixo
}


def _validate_magic_bytes(content: bytes, content_type: str) -> bool:
    signatures = _MAGIC_BYTES.get(content_type, [])
    if not signatures:
        return False
    if not any(content.startswith(sig) for sig in signatures):
        return False
    # WebP exige "WEBP" nos bytes 8–12 além do "RIFF" inicial
    if content_type == "image/webp" and content[8:12] != b"WEBP":
        return False
    return True


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

    if not _validate_magic_bytes(content, file.content_type):
        raise HTTPException(
            status_code=400,
            detail="Conteúdo do arquivo não corresponde ao formato declarado.",
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