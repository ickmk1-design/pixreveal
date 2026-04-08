from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from ..database import get_db
from ..models.user import User
from ..schemas.leaderboard import LeaderboardEntry, LeaderboardResponse

router = APIRouter(prefix="/api/leaderboard", tags=["leaderboard"])


@router.get("/", response_model=LeaderboardResponse)
async def get_leaderboard(
    limit: int = 50,
    offset: int = 0,
    db: AsyncSession = Depends(get_db),
):
    # Count total
    count_result = await db.execute(select(func.count(User.id)))
    total = count_result.scalar() or 0

    # Get top users
    result = await db.execute(
        select(User)
        .order_by(User.total_stars.desc(), User.levels_completed.desc())
        .offset(offset)
        .limit(limit)
    )
    users = result.scalars().all()

    entries = []
    for i, user in enumerate(users):
        entries.append(
            LeaderboardEntry(
                rank=offset + i + 1,
                user_id=user.id,
                display_name=user.display_name or "Anonymous",
                total_stars=user.total_stars,
                levels_completed=user.levels_completed,
            )
        )

    return LeaderboardResponse(entries=entries, total=total)
