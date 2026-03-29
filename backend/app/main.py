"""
ET NEXUS — FastAPI Application Entry Point
"""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.middleware import RequestLoggingMiddleware
from app.api.v1 import chat, user, event, recommend, news
from app.db.session import init_db

# ── Logging ──
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format="%(asctime)s | %(name)s | %(levelname)s | %(message)s",
)
logger = logging.getLogger("et_concierge")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application startup and shutdown lifecycle."""
    logger.info(f"🚀 {settings.APP_NAME} v{settings.APP_VERSION} starting up...")
    logger.info(f"📊 Debug mode: {settings.DEBUG}")
    logger.info(f"🤖 LLM Model: {settings.OPENAI_MODEL}")

    has_api_key = bool(settings.OPENAI_API_KEY)
    logger.info(f"🔑 OpenAI API Key: {'configured' if has_api_key else 'NOT SET — running in demo mode'}")

    # Auto-create database tables
    await init_db()
    logger.info("📦 Database tables initialized")

    yield

    logger.info("👋 Shutting down ET Financial Concierge...")


# ── FastAPI App ──
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description=(
        "An AI-powered conversational concierge that helps users discover "
        "and navigate the complete Economic Times ecosystem through a single, "
        "intelligent chat interface."
    ),
    lifespan=lifespan,
)

# ── Middleware ──
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(RequestLoggingMiddleware)

# ── API Routers ──
app.include_router(chat.router, prefix="/api/v1/chat", tags=["💬 Chat"])
app.include_router(user.router, prefix="/api/v1/user", tags=["👤 User"])
app.include_router(event.router, prefix="/api/v1/event", tags=["📊 Events"])
app.include_router(recommend.router, prefix="/api/v1/recommend", tags=["🎯 Recommendations"])
app.include_router(news.router, prefix="/api/v1/news", tags=["📰 News"])


@app.get("/", tags=["🏠 Health"])
def health_check():
    """API health check endpoint."""
    return {
        "status": "healthy",
        "service": settings.APP_NAME,
        "version": settings.APP_VERSION,
    }


@app.get("/api/v1/status", tags=["🏠 Health"])
def api_status():
    """Detailed API status with feature flags."""
    return {
        "status": "operational",
        "features": {
            "chat": True,
            "profiling": True,
            "recommendations": True,
            "event_tracking": True,
            "rag_pipeline": bool(settings.OPENAI_API_KEY),
            "auth": True,
        },
        "llm_mode": "openai" if settings.OPENAI_API_KEY else "demo",
        "model": settings.OPENAI_MODEL,
    }
