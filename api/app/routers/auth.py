from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete
from ..database import get_db
from ..models.user import User
from ..models.score import Score
from ..schemas.user import UserCreate, UserResponse

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register", response_model=UserResponse)
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_db)):
    # Check if user already exists
    result = await db.execute(select(User).where(User.id == user_data.id))
    existing = result.scalar_one_or_none()

    if existing:
        return existing

    user = User(
        id=user_data.id,
        display_name=user_data.display_name,
        email=user_data.email,
        is_anonymous=user_data.is_anonymous,
        tokens=5,  # Starting tokens
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


@router.get("/me", response_model=UserResponse)
async def get_me(user_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.delete("/account")
async def delete_account(user_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    await db.execute(delete(Score).where(Score.user_id == user_id))
    await db.execute(delete(User).where(User.id == user_id))
    await db.commit()

    return {"success": True, "message": "Account and all data deleted"}
