"""
SQLAlchemy ORM models for all 13 tables in the ET Financial Concierge schema.
(SQLite-compatible version for local development)
"""
import uuid
import json
from datetime import datetime, timezone
from sqlalchemy import (
    Column, String, Text, Boolean, Integer, BigInteger, SmallInteger, Float,
    ForeignKey, DateTime, Index, JSON
)
from sqlalchemy.orm import relationship

from app.db.session import Base


def utcnow():
    return datetime.now(timezone.utc)


def new_uuid():
    return str(uuid.uuid4())


# ═══════════════════════════════════════════════════════════════
# 1. USERS
# ═══════════════════════════════════════════════════════════════
class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=new_uuid)
    email = Column(String(255), unique=True, nullable=False, index=True)
    full_name = Column(String(200), nullable=False)
    phone = Column(String(20))
    avatar_url = Column(Text)
    auth_provider = Column(String(50), nullable=False, default="email")
    hashed_password = Column(Text)
    is_verified = Column(Boolean, nullable=False, default=False)
    is_active = Column(Boolean, nullable=False, default=True)
    et_prime_member = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime, nullable=False, default=utcnow)
    updated_at = Column(DateTime, nullable=False, default=utcnow, onupdate=utcnow)

    # Relationships
    insights = relationship("UserInsight", back_populates="user", uselist=False, cascade="all, delete-orphan")
    events = relationship("UserEvent", back_populates="user", cascade="all, delete-orphan")
    conversations = relationship("Conversation", back_populates="user", cascade="all, delete-orphan")
    recommendations = relationship("Recommendation", back_populates="user", cascade="all, delete-orphan")
    sessions = relationship("Session", back_populates="user", cascade="all, delete-orphan")
    feedbacks = relationship("Feedback", back_populates="user", cascade="all, delete-orphan")


# ═══════════════════════════════════════════════════════════════
# 2. USER_INSIGHTS
# ═══════════════════════════════════════════════════════════════
class UserInsight(Base):
    __tablename__ = "user_insights"

    id = Column(String(36), primary_key=True, default=new_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True)

    income_bracket = Column(String(50))
    investment_horizon = Column(String(50))
    risk_appetite = Column(String(30))
    financial_goals = Column(JSON, default=[])
    preferred_sectors = Column(JSON, default=[])
    existing_portfolio = Column(JSON, default={})

    experience_level = Column(String(30))
    knowledge_areas = Column(JSON, default=[])
    preferred_content = Column(JSON, default=[])
    notification_prefs = Column(JSON, default={})
    confidence_scores = Column(JSON, default={})

    profiling_complete = Column(Boolean, nullable=False, default=False)
    last_profiled_at = Column(DateTime)
    created_at = Column(DateTime, nullable=False, default=utcnow)
    updated_at = Column(DateTime, nullable=False, default=utcnow, onupdate=utcnow)

    user = relationship("User", back_populates="insights")


# ═══════════════════════════════════════════════════════════════
# 3. USER_EVENTS
# ═══════════════════════════════════════════════════════════════
class UserEvent(Base):
    __tablename__ = "user_events"

    id = Column(String(36), primary_key=True, default=new_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    event_type = Column(String(100), nullable=False)
    event_source = Column(String(50), nullable=False, default="app")
    entity_type = Column(String(50))
    entity_id = Column(String(36))
    event_data = Column(JSON, default={})
    session_id = Column(String(36))
    created_at = Column(DateTime, nullable=False, default=utcnow)

    user = relationship("User", back_populates="events")


# ═══════════════════════════════════════════════════════════════
# 4. PRODUCTS
# ═══════════════════════════════════════════════════════════════
class Product(Base):
    __tablename__ = "products"

    id = Column(String(36), primary_key=True, default=new_uuid)
    name = Column(String(300), nullable=False)
    slug = Column(String(300), unique=True, nullable=False, index=True)
    category = Column(String(100), nullable=False, index=True)
    sub_category = Column(String(100))
    provider = Column(String(200))
    description = Column(Text)
    features = Column(JSON, default=[])
    pricing = Column(JSON, default={})
    risk_category = Column(String(30))
    suitability = Column(JSON, default={})
    url = Column(Text)
    image_url = Column(Text)
    is_active = Column(Boolean, nullable=False, default=True)
    metadata_ = Column("metadata", JSON, default={})
    created_at = Column(DateTime, nullable=False, default=utcnow)
    updated_at = Column(DateTime, nullable=False, default=utcnow, onupdate=utcnow)


# ═══════════════════════════════════════════════════════════════
# 5. CONTENT
# ═══════════════════════════════════════════════════════════════
class Content(Base):
    __tablename__ = "content"

    id = Column(String(36), primary_key=True, default=new_uuid)
    title = Column(String(500), nullable=False)
    slug = Column(String(500), unique=True, nullable=False, index=True)
    content_type = Column(String(50), nullable=False, index=True)
    source = Column(String(100), nullable=False, default="et_prime")
    author = Column(String(200))
    summary = Column(Text)
    body = Column(Text)
    tags = Column(JSON, default=[])
    sectors = Column(JSON, default=[])
    difficulty = Column(String(30))
    is_premium = Column(Boolean, nullable=False, default=False)
    url = Column(Text)
    image_url = Column(Text)
    # embedding skipped for SQLite (no pgvector)
    published_at = Column(DateTime)
    is_active = Column(Boolean, nullable=False, default=True)
    metadata_ = Column("metadata", JSON, default={})
    created_at = Column(DateTime, nullable=False, default=utcnow)
    updated_at = Column(DateTime, nullable=False, default=utcnow, onupdate=utcnow)

    chunks = relationship("ContentChunk", back_populates="content", cascade="all, delete-orphan")


# ═══════════════════════════════════════════════════════════════
# 6. CONTENT_CHUNKS
# ═══════════════════════════════════════════════════════════════
class ContentChunk(Base):
    __tablename__ = "content_chunks"

    id = Column(String(36), primary_key=True, default=new_uuid)
    content_id = Column(String(36), ForeignKey("content.id", ondelete="CASCADE"), nullable=False)
    chunk_index = Column(Integer, nullable=False)
    chunk_text = Column(Text, nullable=False)
    token_count = Column(Integer)
    # embedding skipped for SQLite (no pgvector)
    created_at = Column(DateTime, nullable=False, default=utcnow)

    content = relationship("Content", back_populates="chunks")


# ═══════════════════════════════════════════════════════════════
# 7. RECOMMENDATIONS
# ═══════════════════════════════════════════════════════════════
class Recommendation(Base):
    __tablename__ = "recommendations"

    id = Column(String(36), primary_key=True, default=new_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    conversation_id = Column(String(36))

    recommendation_type = Column(String(50), nullable=False)
    entity_type = Column(String(50))
    entity_id = Column(String(36))

    title = Column(String(500))
    explanation = Column(Text, nullable=False)
    confidence_score = Column(Float)
    relevance_factors = Column(JSON, default=[])

    prompt_snapshot = Column(Text)
    context_sources = Column(JSON, default=[])
    model_version = Column(String(100))

    status = Column(String(30), nullable=False, default="pending")
    user_rating = Column(SmallInteger)
    user_feedback = Column(Text)

    created_at = Column(DateTime, nullable=False, default=utcnow)
    expires_at = Column(DateTime)

    user = relationship("User", back_populates="recommendations")


# ═══════════════════════════════════════════════════════════════
# 8. CONVERSATIONS
# ═══════════════════════════════════════════════════════════════
class Conversation(Base):
    __tablename__ = "conversations"

    id = Column(String(36), primary_key=True, default=new_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(300))
    status = Column(String(30), nullable=False, default="active")
    intent_tags = Column(JSON, default=[])
    profiling_stage = Column(String(50))
    summary = Column(Text)
    message_count = Column(Integer, nullable=False, default=0)
    created_at = Column(DateTime, nullable=False, default=utcnow)
    updated_at = Column(DateTime, nullable=False, default=utcnow, onupdate=utcnow)

    user = relationship("User", back_populates="conversations")
    messages = relationship("Message", back_populates="conversation", cascade="all, delete-orphan")


# ═══════════════════════════════════════════════════════════════
# 9. MESSAGES
# ═══════════════════════════════════════════════════════════════
class Message(Base):
    __tablename__ = "messages"

    id = Column(String(36), primary_key=True, default=new_uuid)
    conversation_id = Column(String(36), ForeignKey("conversations.id", ondelete="CASCADE"), nullable=False)
    role = Column(String(20), nullable=False)
    content = Column(Text, nullable=False)
    intent = Column(String(100))
    entities = Column(JSON, default=[])
    tool_calls = Column(JSON, default=[])
    token_usage = Column(JSON, default={})
    latency_ms = Column(Integer)
    created_at = Column(DateTime, nullable=False, default=utcnow)

    conversation = relationship("Conversation", back_populates="messages")


# ═══════════════════════════════════════════════════════════════
# 10. SESSIONS
# ═══════════════════════════════════════════════════════════════
class Session(Base):
    __tablename__ = "sessions"

    id = Column(String(36), primary_key=True, default=new_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    device_info = Column(JSON, default={})
    ip_address = Column(String(45))
    started_at = Column(DateTime, nullable=False, default=utcnow)
    ended_at = Column(DateTime)
    is_active = Column(Boolean, nullable=False, default=True)

    user = relationship("User", back_populates="sessions")


# ═══════════════════════════════════════════════════════════════
# 11. FEEDBACK
# ═══════════════════════════════════════════════════════════════
class Feedback(Base):
    __tablename__ = "feedback"

    id = Column(String(36), primary_key=True, default=new_uuid)
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    conversation_id = Column(String(36), ForeignKey("conversations.id", ondelete="SET NULL"))
    rating = Column(SmallInteger, nullable=False)
    category = Column(String(50))
    comment = Column(Text)
    created_at = Column(DateTime, nullable=False, default=utcnow)

    user = relationship("User", back_populates="feedbacks")


# ═══════════════════════════════════════════════════════════════
# 12. PROMPT_TEMPLATES
# ═══════════════════════════════════════════════════════════════
class PromptTemplate(Base):
    __tablename__ = "prompt_templates"

    id = Column(String(36), primary_key=True, default=new_uuid)
    name = Column(String(200), unique=True, nullable=False)
    template = Column(Text, nullable=False)
    version = Column(Integer, nullable=False, default=1)
    variables = Column(JSON, default=[])
    is_active = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, nullable=False, default=utcnow)
    updated_at = Column(DateTime, nullable=False, default=utcnow, onupdate=utcnow)


# ═══════════════════════════════════════════════════════════════
# 13. AUDIT_LOG
# ═══════════════════════════════════════════════════════════════
class AuditLog(Base):
    __tablename__ = "audit_log"

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(String(36))
    action = Column(String(200), nullable=False)
    resource_type = Column(String(100))
    resource_id = Column(String(36))
    details = Column(JSON, default={})
    ip_address = Column(String(45))
    created_at = Column(DateTime, nullable=False, default=utcnow)
