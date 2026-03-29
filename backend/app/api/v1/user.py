from typing import Optional
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.db.session import get_db
from app.models.database import User, UserInsight
from app.schemas.user_schema import (
    UserRegisterRequest, UserLoginRequest, AuthResponse,
    UserProfile, UserProfileUpdate, UserInsightsResponse,
)
from app.core.security import (
    hash_password, verify_password, create_access_token, get_current_user_id,
)

router = APIRouter()


@router.post("/register", response_model=AuthResponse)
async def register(request: UserRegisterRequest, db: AsyncSession = Depends(get_db)):
    """Create a new user account."""
    # Check if user exists
    result = await db.execute(select(User).where(User.email == request.email))
    if result.scalars().first():
        raise HTTPException(status_code=400, detail="Email already registered")

    # Create user
    new_user = User(
        email=request.email,
        full_name=request.full_name,
        phone=request.phone,
        hashed_password=hash_password(request.password),
    )
    db.add(new_user)
    await db.flush()  # To get new_user.id

    # Initialize insights
    new_insight = UserInsight(user_id=new_user.id)
    db.add(new_insight)
    
    await db.commit()
    await db.refresh(new_user)

    token = create_access_token({"sub": str(new_user.id), "email": new_user.email})

    return AuthResponse(
        access_token=token,
        user_id=str(new_user.id),
        full_name=new_user.full_name,
    )


@router.post("/login", response_model=AuthResponse)
async def login(request: UserLoginRequest, db: AsyncSession = Depends(get_db)):
    """Authenticate and receive JWT."""
    result = await db.execute(select(User).where(User.email == request.email))
    user = result.scalars().first()

    if not user or not verify_password(request.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid email or password")

    token = create_access_token({"sub": str(user.id), "email": user.email})

    return AuthResponse(
        access_token=token,
        user_id=str(user.id),
        full_name=user.full_name,
    )


@router.get("/profile", response_model=UserProfile)
async def get_profile(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get current user profile."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalars().first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return UserProfile(
        id=str(user.id),
        email=user.email,
        full_name=user.full_name,
        phone=user.phone,
        avatar_url=user.avatar_url,
        et_prime_member=user.et_prime_member,
        created_at=user.created_at
    )


@router.patch("/profile", response_model=UserProfile)
async def update_profile(
    updates: UserProfileUpdate,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Update user profile fields."""
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalars().first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    update_data = updates.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(user, key, value)

    await db.commit()
    await db.refresh(user)

    return UserProfile(
        id=str(user.id),
        email=user.email,
        full_name=user.full_name,
        phone=user.phone,
        avatar_url=user.avatar_url,
        et_prime_member=user.et_prime_member,
        created_at=user.created_at
    )


@router.get("/insights", response_model=UserInsightsResponse)
async def get_insights(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db)
):
    """Get AI-derived financial profile insights."""
    result = await db.execute(select(UserInsight).where(UserInsight.user_id == user_id))
    insights = result.scalars().first()
    
    if not insights:
        return UserInsightsResponse()

    return UserInsightsResponse(
        risk_appetite=insights.risk_appetite,
        financial_goals=insights.financial_goals,
        investment_horizon=insights.investment_horizon,
        experience_level=insights.experience_level,
        income_bracket=insights.income_bracket,
        preferred_sectors=insights.preferred_sectors,
        existing_portfolio=insights.existing_portfolio,
        confidence_scores=insights.confidence_scores,
        profiling_complete=insights.profiling_complete
    )

