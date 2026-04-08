from sqlalchemy import Column, String, Integer, Float, DateTime, func, ForeignKey
from ..database import Base


class Score(Base):
    __tablename__ = "scores"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)
    level_id = Column(Integer, nullable=False)
    stars = Column(Integer, default=0)
    captured_percent = Column(Float, default=0)
    time_seconds = Column(Integer, default=0)
    created_at = Column(DateTime, server_default=func.now())
