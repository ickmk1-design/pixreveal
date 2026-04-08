import redis.asyncio as redis
from .config import get_settings

settings = get_settings()

redis_client = redis.from_url(settings.redis_url, decode_responses=True)


async def get_redis():
    return redis_client
