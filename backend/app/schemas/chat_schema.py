"""
Complete Pydantic schemas for Chat endpoints — enforces the strict JSON
output format required by the AI concierge system prompt.
"""
from pydantic import BaseModel, Field
from typing import List, Optional, Any, Dict
from datetime import datetime


# ── Entities extracted from user messages ──
class ExtractedEntity(BaseModel):
    type: str = Field(description="amount | goal | duration | ticker | sector")
    value: Any


# ── Message payload ──
class MessageContent(BaseModel):
    content: str
    intent: str = Field(description="investment_query | content_discovery | product_discovery | event_search | profiling | general_chat")
    entities: List[ExtractedEntity] = []


# ── Profile update signals ──
class RiskAppetiteUpdate(BaseModel):
    value: str = Field(description="conservative | moderate | aggressive")
    confidence: float = Field(ge=0.0, le=1.0)


class ProfileUpdates(BaseModel):
    risk_appetite: Optional[RiskAppetiteUpdate] = None
    financial_goals: Optional[List[str]] = None
    investment_horizon: Optional[str] = None
    experience_level: Optional[str] = None


# ── Recommendation item ──
class RecommendationOutput(BaseModel):
    title: str
    type: str = Field(description="product | content | event")
    entity_id: Optional[str] = None
    explanation: str
    confidence_score: float = Field(ge=0.0, le=1.0)
    relevance_factors: List[str] = []


# ── Full RAG pipeline output (strict JSON the LLM must return) ──
class RagResponse(BaseModel):
    model_config = {"arbitrary_types_allowed": True}

    message: MessageContent
    conversation_id: Optional[str] = None
    profile_updates: Optional[ProfileUpdates] = None
    recommendations: List[RecommendationOutput] = []
    next_profiling_stage: str = Field(description="intro | goals | risk | portfolio | complete")


# ── API Request / Response ──
class ChatRequest(BaseModel):
    conversation_id: Optional[str] = None
    message: str
    context: Optional[Dict[str, Any]] = None


class ChatMessageResponse(BaseModel):
    id: Optional[str] = None
    role: str
    content: str
    intent: Optional[str] = None
    entities: List[Dict[str, Any]] = []


class ChatResponse(BaseModel):
    conversation_id: str
    message: ChatMessageResponse
    recommendations: List[RecommendationOutput] = []
    profiling_stage: str
    profile_updates: Optional[ProfileUpdates] = None


class ConversationSummary(BaseModel):
    id: str
    title: Optional[str] = None
    status: str
    profiling_stage: Optional[str] = None
    message_count: int
    created_at: datetime
    updated_at: datetime


class ConversationDetail(ConversationSummary):
    messages: List[ChatMessageResponse] = []
    summary: Optional[str] = None
