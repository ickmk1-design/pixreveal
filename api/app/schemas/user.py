from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class UserCreate(BaseModel):
    id: str
    display_name: Optional[str] = None
    email: Optional[str] = None
    is_anonymous: bool = True


class UserResponse(BaseModel):
    id: str
    display_name: Optional[str]
    email: Optional[str]
    is_anonymous: bool
    is_premium: bool
    tokens: int
    total_stars: int
    levels_completed: int

    class Config:
        from_attributes = True


class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    email: Optional[str] = None
