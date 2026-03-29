"""
Recommend Router — /api/v1/recommend
Handles personalized recommendation feed, details, and feedback.
"""
import uuid
from datetime import datetime, timezone
from fastapi import APIRouter, HTTPException, Depends, Query
from typing import Optional, Dict, Any, List

from app.schemas.recommend_schema import (
    RecommendationItem, RecommendationFeedResponse,
    RecommendationDetail, RecommendationFeedbackRequest,
)
from app.services.recommendation_service import RecommendationService
from app.core.security import get_current_user_id

router = APIRouter()
rec_service = RecommendationService()

# ── In-memory recommendation store ──
_recommendations: Dict[str, List[Dict[str, Any]]] = {}


@router.get("/feed", response_model=RecommendationFeedResponse)
async def get_recommendation_feed(
    page: int = Query(1, ge=1),
    category: Optional[str] = None,
    user_id: Optional[str] = Depends(get_current_user_id),
):
    """Get personalized recommendation feed."""
    uid = user_id or "anonymous"
    user_recs = _recommendations.get(uid, [])

    if category:
        user_recs = [r for r in user_recs if r.get("type") == category]

    # Sort by confidence score
    user_recs.sort(key=lambda r: r.get("confidence", r.get("confidence_score", 0)), reverse=True)

    page_size = 10
    start = (page - 1) * page_size
    page_recs = user_recs[start:start + page_size]

    items = []
    for r in page_recs:
        items.append(RecommendationItem(
            id=r.get("id", str(uuid.uuid4())),
            type=r.get("type", "product"),
            title=r.get("title", ""),
            explanation=r.get("explanation", ""),
            confidence=r.get("confidence_score", r.get("confidence", 0.5)),
            relevance_factors=r.get("relevance_factors", []),
            entity_type=r.get("entity_type"),
            entity_id=r.get("entity_id"),
        ))

    return RecommendationFeedResponse(
        recommendations=items,
        total=len(user_recs),
        page=page,
    )


@router.get("/{rec_id}", response_model=RecommendationDetail)
async def get_recommendation_detail(
    rec_id: str,
    user_id: Optional[str] = Depends(get_current_user_id),
):
    """Get detailed recommendation with full explanation."""
    uid = user_id or "anonymous"
    user_recs = _recommendations.get(uid, [])

    rec = next((r for r in user_recs if r.get("id") == rec_id), None)
    if not rec:
        raise HTTPException(status_code=404, detail="Recommendation not found")

    return RecommendationDetail(
        id=rec["id"],
        type=rec.get("type", "product"),
        title=rec.get("title", ""),
        explanation=rec.get("explanation", ""),
        confidence=rec.get("confidence_score", 0.5),
        relevance_factors=rec.get("relevance_factors", []),
        context_sources=rec.get("context_sources", []),
        model_version=rec.get("model_version"),
        created_at=rec.get("created_at", datetime.now(timezone.utc)),
    )


@router.post("/{rec_id}/feedback")
async def submit_feedback(
    rec_id: str,
    feedback: RecommendationFeedbackRequest,
    user_id: Optional[str] = Depends(get_current_user_id),
):
    """Submit rating/feedback on a recommendation."""
    uid = user_id or "anonymous"
    user_recs = _recommendations.get(uid, [])

    rec = next((r for r in user_recs if r.get("id") == rec_id), None)
    if not rec:
        raise HTTPException(status_code=404, detail="Recommendation not found")

    rec["user_rating"] = feedback.rating
    rec["user_feedback"] = feedback.comment
    rec["status"] = "accepted" if feedback.rating >= 4 else "dismissed"

    return {
        "status": "feedback_recorded",
        "rec_id": rec_id,
        "rating": feedback.rating,
    }


@router.get("/products/catalog")
async def get_product_recommendations(
    category: Optional[str] = None,
    risk: Optional[str] = None,
    user_id: Optional[str] = Depends(get_current_user_id),
):
    """Get product recommendations filtered by category and risk."""
    # In production, this queries the products table
    sample_products = [
        {
            "id": "prod_sbi_blue",
            "name": "SBI Bluechip Fund — Direct Growth",
            "category": "mutual_fund",
            "risk_category": "moderate",
            "description": "Large-cap equity fund with consistent long-term returns.",
            "suitability": {"min_experience": "beginner", "goals": ["retirement", "wealth_creation"], "horizon": "long_term"},
        },
        {
            "id": "prod_hdfc_bal",
            "name": "HDFC Balanced Advantage Fund — Direct Growth",
            "category": "mutual_fund",
            "risk_category": "conservative",
            "description": "Dynamic asset allocation fund balancing equity and debt.",
            "suitability": {"min_experience": "beginner", "goals": ["retirement", "wealth_creation"], "horizon": "long_term"},
        },
        {
            "id": "prod_quant_sc",
            "name": "Quant Small Cap Fund — Direct Growth",
            "category": "mutual_fund",
            "risk_category": "aggressive",
            "description": "High-growth small-cap fund with strong momentum.",
            "suitability": {"min_experience": "intermediate", "goals": ["wealth_creation"], "horizon": "long_term"},
        },
        {
            "id": "prod_et_prime",
            "name": "ET Prime Annual Membership",
            "category": "et_prime",
            "risk_category": None,
            "description": "Unlimited access to premium financial analysis and expert insights.",
            "suitability": {"min_experience": "beginner", "goals": ["wealth_creation", "tax_saving"]},
        },
        {
            "id": "prod_masterclass",
            "name": "ET Masterclass: Investment Fundamentals",
            "category": "masterclass",
            "risk_category": None,
            "description": "Comprehensive course covering equity, debt, and portfolio construction.",
            "suitability": {"min_experience": "beginner", "goals": ["wealth_creation"]},
        },
    ]

    if category:
        sample_products = [p for p in sample_products if p["category"] == category]
    if risk:
        sample_products = [p for p in sample_products if p.get("risk_category") == risk or p.get("risk_category") is None]

    return {"products": sample_products, "total": len(sample_products)}
