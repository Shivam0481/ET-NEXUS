import asyncio
import uuid
import random
import os
from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

# Add the parent directory to sys.path to import app modules
import sys
from pathlib import Path
sys.path.append(str(Path(__file__).parent.parent))

from app.models.database import Base, Content, ContentChunk
from app.core.config import settings

# Database setup
engine = create_async_engine(settings.DATABASE_URL, echo=True)
AsyncSessionLocal = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

def generate_mock_embedding(dim=1536):
    """Generate a random vector for demonstration."""
    return [random.uniform(-1, 1) for _ in range(dim)]

SAMPLE_DATA = [
    {
        "title": "Mutual Funds for Beginners: A 2024 Guide",
        "source": "ET Learn",
        "content_type": "article",
        "body": "Mutual funds are investment vehicles that pool money from multiple investors to purchase a diversified portfolio of stocks, bonds, or other securities. For beginners, Equity Mutual Funds offer long-term growth potential, while Debt Funds provide relative stability. Systematic Investment Plans (SIPs) are the most disciplined way to invest in mutual funds, allowing you to invest small amounts regularly.",
        "tags": ["mutual_funds", "SIP", "investing"],
        "difficulty": "beginner"
    },
    {
        "title": "Bluechip Equity Fund (Growth)",
        "source": "ET Recommendations",
        "content_type": "product",
        "body": "A top-rated large-cap equity fund focusing on India's 50 largest companies. Ideal for long-term wealth creation with lower volatility than mid-cap funds. 3-year CAGR: 14.5%. Risk Level: Very High (Equity).",
        "tags": ["stocks", "equity", "large_cap"],
        "difficulty": "intermediate"
    },
    {
        "title": "Tax Saving 101: 80C and Beyond",
        "source": "ET Wealth",
        "content_type": "article",
        "body": "Section 80C of the Income Tax Act allows deductions up to Rs 1.5 lakh per year. ELSS (Equity Linked Savings Scheme) is a popular 80C instrument with the shortest lock-in period of 3 years and potential for inflation-beating returns. Other options include PPF, VPF, and NPS.",
        "tags": ["tax", "savings", "planning"],
        "difficulty": "beginner"
    },
    {
        "title": "Market Outlook: Why Nifty is near all-time highs",
        "source": "ET Prime",
        "content_type": "article",
        "body": "The Indian equity market continues to show resilience backed by strong corporate earnings and robust domestic inflows. Analysts expect the IT and Banking sectors to lead the next leg of the rally. Investors should maintain a diversified portfolio and avoid panic selling during minor corrections.",
        "tags": ["markets", "nifty", "economy"],
        "difficulty": "advanced"
    }
]

async def seed_db():
    async with AsyncSessionLocal() as session:
        print("🌱 Seeding content and content_chunks...")
        
        # 1. Ensure pgvector extension exists
        await session.execute(text("CREATE EXTENSION IF NOT EXISTS vector"))
        await session.commit()
        
        for item in SAMPLE_DATA:
            title = str(item["title"])
            body = str(item["body"])
            
            # Create root content
            content_id = uuid.uuid4()
            content = Content(
                id=content_id,
                title=title,
                slug=title.lower().replace(" ", "-"),
                source=item["source"],
                content_type=item["content_type"],
                body=body,
                tags=item["tags"],
                difficulty=item["difficulty"],
                embedding=generate_mock_embedding(),
                is_active=True,
                published_at=datetime.now(timezone.utc)
            )
            session.add(content)
            
            # Create chunks (simple split by sentences for demo)
            sentences = body.split(". ")
            for i, chunk_text in enumerate(sentences):
                chunk = ContentChunk(
                    id=uuid.uuid4(),
                    content_id=content_id,
                    chunk_index=i,
                    chunk_text=chunk_text,
                    token_count=len(chunk_text.split()),
                    embedding=generate_mock_embedding() 
                )
                session.add(chunk)
                
        await session.commit()
        print("✅ Seeding complete!")

if __name__ == "__main__":
    asyncio.run(seed_db())
