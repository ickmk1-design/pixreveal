from pydantic import BaseModel


class TokenBalance(BaseModel):
    tokens: int
    ads_watched_today: int
    can_watch_ad: bool
    daily_login_available: bool


class TokenAction(BaseModel):
    action: str  # "daily_login", "ad_reward", "use_token", "three_star_bonus"
    amount: int = 0


class TokenResponse(BaseModel):
    success: bool
    tokens: int
    message: str
