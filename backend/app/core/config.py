"""
ET AI Financial Concierge — Application Configuration
Loads environment variables and provides typed settings.
"""
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    # ── Application ──
    APP_NAME: str = "ET NEXUS"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True
    LOG_LEVEL: str = "INFO"

    # ── Database (SQLite for local dev) ──
    DATABASE_URL: str = "sqlite+aiosqlite:///./etconcierge.db"

    # ── Redis ──
    REDIS_URL: str = "redis://localhost:6379/0"

    # ── OpenAI ──
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-4-turbo"
    OPENAI_EMBEDDING_MODEL: str = "text-embedding-ada-002"
    EMBEDDING_DIMENSIONS: int = 1536

    # ── JWT Auth ──
    JWT_SECRET: str = "super-secret-change-me-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRY_HOURS: int = 24

    # ── ET APIs ──
    ET_API_BASE_URL: str = "https://api.economictimes.com/v1"
    ET_API_KEY: str = ""

    # ── News API ──
    NEWS_API_KEY: str = ""

    # ── RAG Config ──
    RAG_TOP_K: int = 5
    RAG_SIMILARITY_THRESHOLD: float = 0.72
    MAX_CONVERSATION_HISTORY: int = 10
    MAX_CONTEXT_TOKENS: int = 4800

    # ── Rate Limiting ──
    RATE_LIMIT_REQUESTS: int = 60
    RATE_LIMIT_WINDOW_SECONDS: int = 60

    # ── Guest Sessions ──
    GUEST_USER_ID: str = "00000000-0000-0000-0000-000000000000"

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()

