from pydantic import BaseModel
from typing import Optional


class ScoreSubmit(BaseModel):
    level_id: int
    stars: int
    captured_percent: float
    time_seconds: int


class ScoreResponse(BaseModel):
    id: int
    user_id: str
    level_id: int
    stars: int
    captured_percent: float
    time_seconds: int

    class Config:
        from_attributes = True
