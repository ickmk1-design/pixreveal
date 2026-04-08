from sqlalchemy import Column, String, Boolean, Integer, DateTime, func
from ..database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(String, primary_key=True)  # Firebase UID
    display_name = Column(String, nullable=True)
    email = Column(String, nullable=True)
    is_anonymous = Column(Boolean, default=True)
    is_premium = Column(Boolean, default=False)
    tokens = Column(Integer, default=5)
    total_stars = Column(Integer, default=0)
    levels_completed = Column(Integer, default=0)
    ads_watched_today = Column(Integer, default=0)
    last_daily_login = Column(DateTime, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
