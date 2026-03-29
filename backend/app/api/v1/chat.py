import uuid
from fastapi import APIRouter, HTTPException, Depends
from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from app.schemas.chat_schema import (
    ChatRequest, ChatResponse, ChatMessageResponse,
    ConversationSummary, ConversationDetail,
)
from app.services.ai_orchestrator import AIOrchestrator
from app.core.security import get_current_user_id
from app.db.session import get_db
from app.models.database import Conversation, Message

router = APIRouter()
ai_service = AIOrchestrator()


@router.post("/message", response_model=ChatResponse)
async def send_message(
    request: ChatRequest,
    user_id: Optional[str] = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """
    Send a user message to the AI concierge.
    Returns structured response with recommendations and profiling stage.
    """
    conv_id = request.conversation_id
    
    try:
        rag_response = await ai_service.process_message(
            conversation_id=conv_id,
            user_input=request.message,
            context=request.context,
            user_id=user_id,
            db=db
        )

        return ChatResponse(
            conversation_id=rag_response.conversation_id or str(uuid.uuid4()),
            message=ChatMessageResponse(
                id=str(uuid.uuid4()),
                role="assistant",
                content=rag_response.message.content,
                intent=rag_response.message.intent,
                entities=[e.model_dump() for e in rag_response.message.entities],
            ),
            recommendations=rag_response.recommendations,
            profiling_stage=rag_response.next_profiling_stage,
            profile_updates=rag_response.profile_updates,
        )
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/conversations", response_model=List[ConversationSummary])
async def list_conversations(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """List all conversations for the authenticated user."""
    result = await db.execute(
        select(Conversation)
        .where(Conversation.user_id == user_id)
        .order_by(Conversation.updated_at.desc())
    )
    convs = result.scalars().all()
    
    return [
        ConversationSummary(
            id=str(c.id),
            title=c.title,
            status=c.status,
            profiling_stage=c.profiling_stage,
            message_count=c.message_count,
            created_at=c.created_at,
            updated_at=c.updated_at
        ) for c in convs
    ]


@router.get("/conversations/{conversation_id}", response_model=ConversationDetail)
async def get_conversation(
    conversation_id: str,
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve full conversation with messages."""
    result = await db.execute(
        select(Conversation)
        .where(Conversation.id == conversation_id, Conversation.user_id == user_id)
    )
    conv = result.scalars().first()
    
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")

    # Load messages
    msg_result = await db.execute(
        select(Message)
        .where(Message.conversation_id == conversation_id)
        .order_by(Message.created_at.asc())
    )
    messages = msg_result.scalars().all()

    return ConversationDetail(
        id=str(conv.id),
        title=conv.title,
        status=conv.status,
        profiling_stage=conv.profiling_stage,
        message_count=conv.message_count,
        messages=[
            ChatMessageResponse(
                id=str(m.id),
                role=m.role,
                content=m.content,
                intent=m.intent,
                entities=m.entities
            ) for m in messages
        ],
        summary=conv.summary,
        created_at=conv.created_at,
        updated_at=conv.updated_at,
    )


@router.delete("/conversations/{conversation_id}")
async def delete_conversation(
    conversation_id: str,
    user_id: Optional[str] = Depends(get_current_user_id),
):
    """Archive/delete a conversation."""
    from app.services.ai_orchestrator import _sessions
    if conversation_id in _sessions:
        del _sessions[conversation_id]
        return {"status": "deleted", "conversation_id": conversation_id}
    raise HTTPException(status_code=404, detail="Conversation not found")
