"""
Event Router — /api/v1/event
Handles behavioral event tracking for personalization.
"""
from typing import Optional, List
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy import func

from app.db.session import get_db
from app.models.database import UserEvent
from app.schemas.event_schema import (
    EventTrackRequest, EventBatchRequest,
    EventResponse, EventHistoryResponse,
)
from app.core.security import get_current_user_id

router = APIRouter()


@router.post("/track", response_model=EventResponse)
async def track_event(
    request: EventTrackRequest,
    user_id: Optional[str] = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Log a single user behavior event."""
    if not user_id:
        raise HTTPException(status_code=401, detail="Authentication required for event tracking")

    new_event = UserEvent(
        user_id=user_id,
        event_type=request.event_type,
        entity_type=request.entity_type,
        entity_id=request.entity_id,
        event_data=request.event_data,
        session_id=request.session_id,
    )
    db.add(new_event)
    await db.commit()
    await db.refresh(new_event)

    return EventResponse(
        id=str(new_event.id),
        event_type=new_event.event_type,
        entity_type=new_event.entity_type,
        entity_id=str(new_event.entity_id) if new_event.entity_id else None,
        event_data=new_event.event_data,
        created_at=new_event.created_at,
    )


@router.post("/batch")
async def track_batch(
    request: EventBatchRequest,
    user_id: Optional[str] = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Log multiple events in batch."""
    if not user_id:
        raise HTTPException(status_code=401, detail="Authentication required for event tracking")

    results = []
    for evt in request.events:
        new_event = UserEvent(
            user_id=user_id,
            event_type=evt.event_type,
            entity_type=evt.entity_type,
            entity_id=evt.entity_id,
            event_data=evt.event_data,
            session_id=evt.session_id,
        )
        db.add(new_event)
        results.append(new_event)

    await db.commit()

    return {
        "tracked": len(results), 
        "events": [
            EventResponse(
                id=str(e.id),
                event_type=e.event_type,
                entity_type=e.entity_type,
                entity_id=str(e.entity_id) if e.entity_id else None,
                event_data=e.event_data,
                created_at=e.created_at,
            ) for e in results
        ]
    }


@router.get("/history", response_model=EventHistoryResponse)
async def get_event_history(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    user_id: Optional[str] = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve paginated event history from DB."""
    if not user_id:
        return EventHistoryResponse(events=[], total=0, page=page, page_size=page_size)

    # Count total
    count_stmt = select(func.count()).select_from(UserEvent).where(UserEvent.user_id == user_id)
    total_result = await db.execute(count_stmt)
    total = total_result.scalar() or 0

    # Fetch page
    stmt = (
        select(UserEvent)
        .where(UserEvent.user_id == user_id)
        .order_by(UserEvent.created_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    result = await db.execute(stmt)
    events = result.scalars().all()

    return EventHistoryResponse(
        events=[
            EventResponse(
                id=str(e.id),
                event_type=e.event_type,
                entity_type=e.entity_type,
                entity_id=str(e.entity_id) if e.entity_id else None,
                event_data=e.event_data,
                created_at=e.created_at,
            ) for e in events
        ],
        total=total,
        page=page,
        page_size=page_size,
    )

