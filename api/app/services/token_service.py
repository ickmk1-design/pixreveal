from datetime import datetime, date
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ..models.user import User
from ..config import get_settings

settings = get_settings()


class TokenService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_balance(self, user_id: str) -> dict:
        user = await self._get_user(user_id)
        if not user:
            return {"tokens": 0, "ads_watched_today": 0, "can_watch_ad": False, "daily_login_available": False}

        today = date.today()
        is_new_day = user.last_daily_login is None or user.last_daily_login.date() != today

        # Reset daily ad count on new day
        if is_new_day and user.ads_watched_today > 0:
            user.ads_watched_today = 0
            await self.db.commit()

        return {
            "tokens": user.tokens,
            "ads_watched_today": user.ads_watched_today,
            "can_watch_ad": user.ads_watched_today < settings.max_ad_rewards_per_day,
            "daily_login_available": is_new_day,
        }

    async def claim_daily_login(self, user_id: str) -> dict:
        user = await self._get_user(user_id)
        if not user:
            return {"success": False, "tokens": 0, "message": "User not found"}

        today = date.today()
        if user.last_daily_login and user.last_daily_login.date() == today:
            return {"success": False, "tokens": user.tokens, "message": "Already claimed today"}

        user.tokens += settings.daily_login_tokens
        user.last_daily_login = datetime.utcnow()
        await self.db.commit()

        return {"success": True, "tokens": user.tokens, "message": f"+{settings.daily_login_tokens} tokens"}

    async def claim_ad_reward(self, user_id: str) -> dict:
        user = await self._get_user(user_id)
        if not user:
            return {"success": False, "tokens": 0, "message": "User not found"}

        if user.ads_watched_today >= settings.max_ad_rewards_per_day:
            return {"success": False, "tokens": user.tokens, "message": "Max ads reached today"}

        user.tokens += settings.ad_reward_tokens
        user.ads_watched_today += 1
        await self.db.commit()

        return {"success": True, "tokens": user.tokens, "message": f"+{settings.ad_reward_tokens} token"}

    async def use_token(self, user_id: str) -> dict:
        user = await self._get_user(user_id)
        if not user:
            return {"success": False, "tokens": 0, "message": "User not found"}

        if user.tokens <= 0:
            return {"success": False, "tokens": 0, "message": "No tokens"}

        user.tokens -= 1
        await self.db.commit()

        return {"success": True, "tokens": user.tokens, "message": f"Token used. {settings.lives_per_token} lives granted"}

    async def award_three_star_bonus(self, user_id: str) -> dict:
        user = await self._get_user(user_id)
        if not user:
            return {"success": False, "tokens": 0, "message": "User not found"}

        user.tokens += settings.three_star_bonus_tokens
        await self.db.commit()

        return {"success": True, "tokens": user.tokens, "message": f"+{settings.three_star_bonus_tokens} bonus token"}

    async def _get_user(self, user_id: str) -> User | None:
        result = await self.db.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()
