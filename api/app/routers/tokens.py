from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from ..database import get_db
from ..schemas.token import TokenBalance, TokenAction, TokenResponse
from ..services.token_service import TokenService

router = APIRouter(prefix="/api/tokens", tags=["tokens"])


@router.get("/balance", response_model=TokenBalance)
async def get_balance(user_id: str, db: AsyncSession = Depends(get_db)):
    service = TokenService(db)
    return await service.get_balance(user_id)


@router.post("/action", response_model=TokenResponse)
async def token_action(
    user_id: str,
    action: TokenAction,
    db: AsyncSession = Depends(get_db),
):
    service = TokenService(db)

    match action.action:
        case "daily_login":
            return await service.claim_daily_login(user_id)
        case "ad_reward":
            return await service.claim_ad_reward(user_id)
        case "use_token":
            return await service.use_token(user_id)
        case "three_star_bonus":
            return await service.award_three_star_bonus(user_id)
        case _:
            return TokenResponse(success=False, tokens=0, message="Unknown action")
