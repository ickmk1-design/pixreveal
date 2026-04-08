from pydantic import BaseModel
from typing import List


class LeaderboardEntry(BaseModel):
    rank: int
    user_id: str
    display_name: str
    total_stars: int
    levels_completed: int


class LeaderboardResponse(BaseModel):
    entries: List[LeaderboardEntry]
    total: int
