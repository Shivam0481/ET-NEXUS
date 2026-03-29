"""
Pydantic schemas for Event tracking endpoints.
"""
from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime


class EventTrackRequest(BaseModel):
    event_type: str = Field(..., description="page_view | article_read | course_enroll | chat_message | recommendation_click | product_inquiry | event_register")
    entity_type: Optional[str] = Field(None, description="article | product | event | masterclass")
    entity_id: Optional[str] = None
    event_data: Dict[str, Any] = {}
    session_id: Optional[str] = None


class EventBatchRequest(BaseModel):
    events: List[EventTrackRequest]


class EventResponse(BaseModel):
    id: str
    event_type: str
    entity_type: Optional[str] = None
    entity_id: Optional[str] = None
    event_data: Dict[str, Any] = {}
    created_at: datetime


class EventHistoryResponse(BaseModel):
    events: List[EventResponse]
    total: int
    page: int
    page_size: int
