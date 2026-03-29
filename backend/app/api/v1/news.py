"""
ET Financial Concierge — News API
Serves real-time financial news from NewsAPI.org with fallback to curated demo data.
"""
import logging
from datetime import datetime, timedelta, timezone
from typing import Optional, List, Dict, Any

import httpx
from fastapi import APIRouter, Query

from app.core.config import settings

logger = logging.getLogger("et_concierge.news")

router = APIRouter()

# ── Category → search queries ──
CATEGORY_QUERIES = {
    "finance": "finance OR economy OR GDP OR fiscal policy OR RBI",
    "investments": "mutual funds OR SIP OR stock market OR equity OR portfolio",
    "banking": "banking OR loans OR interest rate OR UPI OR fintech",
}


async def _fetch_from_newsapi(query: str, page_size: int = 20) -> List[Dict[str, Any]]:
    """Fetch articles from NewsAPI.org."""
    url = "https://newsapi.org/v2/everything"
    params = {
        "q": query,
        "language": "en",
        "sortBy": "publishedAt",
        "pageSize": page_size,
        "apiKey": settings.NEWS_API_KEY,
    }
    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(url, params=params)
        resp.raise_for_status()
        data = resp.json()
        return data.get("articles", [])


def _normalize_article(article: Dict[str, Any], category: str = "finance") -> Dict[str, Any]:
    """Normalize a NewsAPI article into our schema."""
    return {
        "title": article.get("title", ""),
        "description": article.get("description", ""),
        "url": article.get("url", ""),
        "image_url": article.get("urlToImage") or "",
        "source": article.get("source", {}).get("name", "Unknown"),
        "author": article.get("author") or "ET Desk",
        "published_at": article.get("publishedAt", ""),
        "category": category,
    }


def _get_demo_articles() -> List[Dict[str, Any]]:
    """Curated demo articles when no API key is configured."""
    now = datetime.now(timezone.utc)
    return [
        {
            "title": "RBI Keeps Repo Rate Unchanged at 6.5% — What It Means for Your Loans",
            "description": "The Reserve Bank of India maintained its key lending rate, signaling a cautious stance amid global uncertainty. Home loan and auto loan EMIs remain steady for now.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800&q=80",
            "source": "ET Finance",
            "author": "ET Bureau",
            "published_at": (now - timedelta(hours=1)).isoformat(),
            "category": "banking",
        },
        {
            "title": "Sensex Rallies 600 Points as FIIs Turn Net Buyers After 3 Months",
            "description": "Foreign institutional investors pumped ₹4,200 crore into Indian equities, driving a broad-based rally across banking, IT, and auto sectors.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=800&q=80",
            "source": "ET Markets",
            "author": "Rakesh Patil",
            "published_at": (now - timedelta(hours=2)).isoformat(),
            "category": "investments",
        },
        {
            "title": "5 Best Performing Mutual Funds of 2025 — SIPs That Beat the Index",
            "description": "Small-cap and flexi-cap funds lead the performance charts. Quant Small Cap and Parag Parikh Flexi Cap deliver over 25% CAGR in the last 3 years.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=800&q=80",
            "source": "ET Wealth",
            "author": "Priya Sharma",
            "published_at": (now - timedelta(hours=3)).isoformat(),
            "category": "investments",
        },
        {
            "title": "India's GDP Growth Surges to 7.8% — Fastest Among Major Economies",
            "description": "India outpaces China and the US with robust economic growth driven by manufacturing, services, and government capex spending.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=800&q=80",
            "source": "ET Economy",
            "author": "ET Bureau",
            "published_at": (now - timedelta(hours=4)).isoformat(),
            "category": "finance",
        },
        {
            "title": "UPI Transactions Cross 16 Billion in March — Digital Payments Boom Continues",
            "description": "India's unified payments interface sets another record. PhonePe and Google Pay dominate with 85% market share as rural adoption accelerates.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&q=80",
            "source": "ET Tech",
            "author": "Amit Verma",
            "published_at": (now - timedelta(hours=5)).isoformat(),
            "category": "banking",
        },
        {
            "title": "Gold Prices Hit All-Time High of ₹72,500 — Should You Invest Now?",
            "description": "Gold surges on global uncertainty and central bank buying. Experts recommend a 10-15% portfolio allocation for hedging against inflation.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1610375461246-83df859d849d?w=800&q=80",
            "source": "ET Wealth",
            "author": "Kavita Mehta",
            "published_at": (now - timedelta(hours=6)).isoformat(),
            "category": "investments",
        },
        {
            "title": "Tax-Saving Deadline: Top ELSS Funds to Invest Before March 31",
            "description": "With the financial year ending, investors rush to lock in Section 80C deductions. Top ELSS picks include Axis Long Term Equity and Mirae Asset Tax Saver.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800&q=80",
            "source": "ET Wealth",
            "author": "Deepak Shenoy",
            "published_at": (now - timedelta(hours=7)).isoformat(),
            "category": "finance",
        },
        {
            "title": "HDFC Bank Q4 Results: Net Profit Jumps 37% to ₹16,512 Crore",
            "description": "India's largest private bank beats estimates with strong retail loan growth and improving asset quality. Stock rises 3% in post-market trading.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1501167786227-4cba60f6d58f?w=800&q=80",
            "source": "ET Markets",
            "author": "Suresh Kumar",
            "published_at": (now - timedelta(hours=8)).isoformat(),
            "category": "banking",
        },
        {
            "title": "New Income Tax Slabs 2025-26: How Much Will You Save Under the New Regime?",
            "description": "The revised tax slabs under the new regime offer higher rebates up to ₹12 lakh income. A detailed comparison shows savings of ₹25,000-₹75,000 for most taxpayers.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1586486855514-8c5e5d6a60f0?w=800&q=80",
            "source": "ET Wealth",
            "author": "Preeti Motiani",
            "published_at": (now - timedelta(hours=9)).isoformat(),
            "category": "finance",
        },
        {
            "title": "Nifty IT Index Surges 4% — TCS, Infosys Lead the Rally on Strong Dollar",
            "description": "IT stocks see a sharp rebound as the US dollar strengthens and deal pipeline commentary from Q4 earnings turns positive.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1518186285589-2f7649de83e0?w=800&q=80",
            "source": "ET Markets",
            "author": "Rajesh Wadhwa",
            "published_at": (now - timedelta(hours=10)).isoformat(),
            "category": "investments",
        },
        {
            "title": "SBI Raises Fixed Deposit Rates by 25 bps for Select Tenures",
            "description": "State Bank of India increases FD rates for 1-3 year tenures, now offering up to 7.25%. Senior citizens get an additional 50 bps premium.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1567427017947-545c5f8d16ad?w=800&q=80",
            "source": "ET Banking",
            "author": "Nishant Vashisth",
            "published_at": (now - timedelta(hours=11)).isoformat(),
            "category": "banking",
        },
        {
            "title": "Budget 2025 Impact: Infra Stocks to Watch as Government Doubles Capex",
            "description": "With the government allocating ₹11.11 lakh crore for infrastructure, construction, cement, and steel stocks are poised for multi-year growth.",
            "url": "https://economictimes.indiatimes.com",
            "image_url": "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800&q=80",
            "source": "ET Prime",
            "author": "Sandeep Tandon",
            "published_at": (now - timedelta(hours=12)).isoformat(),
            "category": "finance",
        },
    ]


@router.get("/feed")
async def get_news_feed(
    category: Optional[str] = Query(None, description="Filter: finance, investments, banking"),
    page_size: int = Query(20, ge=1, le=50),
):
    """
    Get real-time financial news feed.
    Falls back to curated demo data if NEWS_API_KEY is not configured.
    """
    # ── Live mode ──
    if settings.NEWS_API_KEY:
        try:
            if category and category in CATEGORY_QUERIES:
                query = CATEGORY_QUERIES[category]
            else:
                query = "India finance OR stock market OR banking OR mutual funds OR economy"

            raw_articles = await _fetch_from_newsapi(query, page_size)
            articles = [
                _normalize_article(a, category or "finance")
                for a in raw_articles
                if a.get("title") and a.get("title") != "[Removed]"
            ]
            return {"articles": articles, "source": "live", "total": len(articles)}
        except Exception as e:
            logger.warning(f"NewsAPI fetch failed, falling back to demo: {e}")

    # ── Demo mode ──
    articles = _get_demo_articles()
    if category:
        articles = [a for a in articles if a["category"] == category]

    return {"articles": articles, "source": "demo", "total": len(articles)}


@router.get("/category/{category}")
async def get_news_by_category(
    category: str,
    page_size: int = Query(20, ge=1, le=50),
):
    """Get news filtered by category: finance, investments, or banking."""
    if category not in CATEGORY_QUERIES and category != "all":
        return {"articles": [], "source": "demo", "total": 0, "error": f"Unknown category: {category}"}

    if category == "all":
        return await get_news_feed(page_size=page_size)

    return await get_news_feed(category=category, page_size=page_size)
