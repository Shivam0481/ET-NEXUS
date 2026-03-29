"""
Pydantic schemas for Recommendation endpoints.
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime


class RecommendationItem(BaseModel):
    id: str
    type: str = Field(description="product | content | action | portfolio_rebalance")
    title: str
    explanation: str
    confidence: float
    relevance_factors: List[str] = []
    entity_type: Optional[str] = None
    entity_id: Optional[str] = None


class RecommendationFeedResponse(BaseModel):
    recommendations: List[RecommendationItem]
    total: int
    page: int


class RecommendationDetail(RecommendationItem):
    context_sources: List[str] = []
    model_version: Optional[str] = None
    created_at: datetime


class RecommendationFeedbackRequest(BaseModel):
    rating: int = Field(..., ge=1, le=5)
    comment: Optional[str] = None
