import asyncio
import time
from typing import Any

class TTLCache:
    def __init__(self, ttl_seconds: int = 300) -> None:
        self._store: dict[str, tuple[Any, float]] = {}
        self._lock = asyncio.Lock()
        self._ttl = ttl_seconds

    async def get(self, key: str) -> Any | None:
        async with self._lock:
            entry = self._store.get(key)
            if entry:
                value, expires_at = entry
                if time.monotonic() < expires_at:
                    return value
                del self._store[key]
        return None

    async def set(self, key: str, value: Any, ttl: int | None = None) -> None:
        async with self._lock:
            self._store[key] = (value, time.monotonic() + (ttl or self._ttl))

    async def invalidate(self, prefix: str) -> None:
        async with self._lock:
            keys = [k for k in list(self._store) if k.startswith(prefix)]
            for k in keys:
                del self._store[k]

brands_cache = TTLCache(ttl_seconds=300)
services_cache = TTLCache(ttl_seconds=300)
showcases_cache = TTLCache(ttl_seconds=300)
slots_cache = TTLCache(ttl_seconds=60)
