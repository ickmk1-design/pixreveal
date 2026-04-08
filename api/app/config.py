import os
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    app_name: str = "PixReveal API"
    debug: bool = False

    # Database
    db_host: str = os.getenv("DB_HOST", "db")
    db_port: int = int(os.getenv("DB_PORT", "5432"))
    db_name: str = os.getenv("DB_NAME", "pixreveal")
    db_user: str = os.getenv("DB_USER", "postgres")
    db_password: str = os.getenv("DB_PASSWORD", "changeme")

    # Redis
    redis_host: str = os.getenv("REDIS_HOST", "redis")
    redis_port: int = int(os.getenv("REDIS_PORT", "6379"))

    # JWT
    secret_key: str = os.getenv("SECRET_KEY", "dev-secret-change-in-prod")
    algorithm: str = "HS256"

    # Token economy defaults
    daily_login_tokens: int = 2
    ad_reward_tokens: int = 1
    max_ad_rewards_per_day: int = 10
    three_star_bonus_tokens: int = 1
    lives_per_token: int = 3

    @property
    def database_url(self) -> str:
        return f"postgresql+asyncpg://{self.db_user}:{self.db_password}@{self.db_host}:{self.db_port}/{self.db_name}"

    @property
    def redis_url(self) -> str:
        return f"redis://{self.redis_host}:{self.redis_port}/0"

    class Config:
        env_file = ".env"


@lru_cache
def get_settings() -> Settings:
    return Settings()
