"""
Pydantic schemas for User endpoints.
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, Dict, Any, List
from datetime import datetime


# ── Registration ──
class UserRegisterRequest(BaseModel):
    email: str = Field(..., max_length=255)
    full_name: str = Field(..., max_length=200)
    password: str = Field(..., min_length=6)
    phone: Optional[str] = None


class UserLoginRequest(BaseModel):
    email: str
    password: str


class AuthResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    full_name: str


# ── Profile ──
class UserProfile(BaseModel):
    id: str
    email: str
    full_name: str
    phone: Optional[str] = None
    avatar_url: Optional[str] = None
    et_prime_member: bool = False
    created_at: Optional[datetime] = None


class UserProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = None


# ── Insights ──
class UserInsightsResponse(BaseModel):
    risk_appetite: Optional[str] = None
    financial_goals: List[str] = []
    investment_horizon: Optional[str] = None
    experience_level: Optional[str] = None
    income_bracket: Optional[str] = None
    preferred_sectors: List[str] = []
    existing_portfolio: Dict[str, Any] = {}
    confidence_scores: Dict[str, float] = {}
    profiling_complete: bool = False
