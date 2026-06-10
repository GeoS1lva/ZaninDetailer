from datetime import datetime, timezone
from functools import lru_cache
from pathlib import Path

import anyio
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

from app.core.config import settings

_SCOPES = ["https://www.googleapis.com/auth/calendar"]
_CREDENTIALS_PATH = Path("credentials/zanin-detailer-4411ff4fff83.json")


@lru_cache(maxsize=1)
def _get_service():
    if not _CREDENTIALS_PATH.exists():
        raise FileNotFoundError(
            f"Arquivo de credenciais não encontrado em {_CREDENTIALS_PATH}. "
            "Faça o download do JSON da Service Account no Google Cloud Console "
            "e salve em credentials/zanin-detailer-4411ff4fff83.json"
        )
    creds = service_account.Credentials.from_service_account_file(
        str(_CREDENTIALS_PATH), scopes=_SCOPES
    )
    return build("calendar", "v3", credentials=creds)


def _sync_create_event(*, title: str, description: str, start: datetime, end: datetime) -> str:
    service = _get_service()
    event = {
        "summary": title,
        "description": description,
        "start": {"dateTime": start.isoformat(), "timeZone": settings.calendar_timezone},
        "end":   {"dateTime": end.isoformat(),   "timeZone": settings.calendar_timezone},
        "colorId": "2",
    }
    created = service.events().insert(calendarId=settings.google_calendar_id, body=event).execute()
    return created["id"]


def _sync_delete_event(event_id: str) -> None:
    service = _get_service()
    try:
        service.events().delete(calendarId=settings.google_calendar_id, eventId=event_id).execute()
    except HttpError as e:
        if e.status_code == 410:
            return
        raise


def _sync_get_busy(start: datetime, end: datetime) -> list[dict]:
    service = _get_service()
    body = {
        "timeMin": start.astimezone(timezone.utc).isoformat(),
        "timeMax": end.astimezone(timezone.utc).isoformat(),
        "items": [{"id": settings.google_calendar_id}],
    }
    result = service.freebusy().query(body=body).execute()
    return result["calendars"][settings.google_calendar_id].get("busy", [])


def _sync_update_event(
    event_id: str,
    *,
    start: datetime,
    end: datetime,
    title: str | None = None,
    description: str | None = None,
) -> None:
    service = _get_service()
    event = service.events().get(calendarId=settings.google_calendar_id, eventId=event_id).execute()
    event["start"] = {"dateTime": start.isoformat(), "timeZone": settings.calendar_timezone}
    event["end"]   = {"dateTime": end.isoformat(),   "timeZone": settings.calendar_timezone}
    if title:
        event["summary"] = title
    if description:
        event["description"] = description
    service.events().update(calendarId=settings.google_calendar_id, eventId=event_id, body=event).execute()

async def create_calendar_event(*, title: str, description: str, start: datetime, end: datetime) -> str:
    return await anyio.to_thread.run_sync(
        lambda: _sync_create_event(title=title, description=description, start=start, end=end)
    )


async def delete_calendar_event(event_id: str) -> None:
    await anyio.to_thread.run_sync(lambda: _sync_delete_event(event_id))


async def get_busy_slots(start: datetime, end: datetime) -> list[dict]:
    return await anyio.to_thread.run_sync(lambda: _sync_get_busy(start, end))


async def update_calendar_event(
    event_id: str,
    *,
    start: datetime,
    end: datetime,
    title: str | None = None,
    description: str | None = None,
) -> None:
    await anyio.to_thread.run_sync(
        lambda: _sync_update_event(event_id, start=start, end=end, title=title, description=description)
    )
