from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from ..database import get_db
from ..models.score import Score
from ..models.user import User
from ..schemas.score import ScoreSubmit, ScoreResponse

router = APIRouter(prefix="/api/scores", tags=["scores"])


@router.post("/submit", response_model=ScoreResponse)
async def submit_score(
    user_id: str,
    score_data: ScoreSubmit,
    db: AsyncSession = Depends(get_db),
):
    score = Score(
        user_id=user_id,
        level_id=score_data.level_id,
        stars=score_data.stars,
        captured_percent=score_data.captured_percent,
        time_seconds=score_data.time_seconds,
    )
    db.add(score)

    # Update user stats if this is a win
    if score_data.stars > 0:
        result = await db.execute(select(User).where(User.id == user_id))
        user = result.scalar_one_or_none()
        if user:
            # Check if first time completing this level
            existing = await db.execute(
                select(Score).where(
                    Score.user_id == user_id,
                    Score.level_id == score_data.level_id,
                    Score.stars > 0,
                )
            )
            if not existing.first():
                user.levels_completed += 1

            user.total_stars = max(user.total_stars, user.total_stars + score_data.stars)

    await db.commit()
    await db.refresh(score)
    return score


@router.get("/best/{level_id}", response_model=ScoreResponse)
async def get_best_score(
    level_id: int,
    user_id: str,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Score)
        .where(Score.user_id == user_id, Score.level_id == level_id)
        .order_by(Score.stars.desc(), Score.captured_percent.desc())
        .limit(1)
    )
    score = result.scalar_one_or_none()
    if not score:
        raise HTTPException(status_code=404, detail="No score found")
    return score
