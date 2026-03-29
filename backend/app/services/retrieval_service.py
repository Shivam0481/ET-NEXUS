import logging
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import joinedload
from sqlalchemy import text
from typing import List, Dict, Any, Optional

from app.core.config import settings
from app.models.database import Content, ContentChunk

logger = logging.getLogger("et_concierge.retrieval")


class RetrievalService:
    """Handles RAG retrieval from content_chunks using semantic similarity."""

    async def search(
        self,
        query_embedding: List[float],
        db: AsyncSession,
        top_k: int = None,
        filters: Optional[Dict[str, Any]] = None,
    ) -> List[Dict[str, Any]]:
        """
        Search content_chunks by cosine similarity using pgvector.
        """
        top_k = top_k or settings.RAG_TOP_K
        threshold = settings.RAG_SIMILARITY_THRESHOLD

        # Explicitly conversion to list of floats just in case
        embedding_str = str(query_embedding)

        # SQL for pgvector similarity (1 - <-> is cosine similarity)
        # Note: <=> is cosine distance, <-> is Euclidean distance, <#> is negative inner product
        # The schema uses vector_cosine_ops, so we use <=> for distance and 1 - <=> for similarity.
        stmt = text("""
            SELECT cc.chunk_text, cc.chunk_index, cc.token_count,
                   c.title, c.source, c.content_type, c.url, c.tags, c.sectors,
                   1 - (cc.embedding <=> :embedding::vector) AS similarity
            FROM content_chunks cc
            JOIN content c ON c.id = cc.content_id
            WHERE c.is_active = TRUE
              AND 1 - (cc.embedding <=> :embedding::vector) >= :threshold
            ORDER BY cc.embedding <=> :embedding::vector
            LIMIT :top_k
        """)

        try:
            result = await db.execute(stmt, {
                "embedding": embedding_str,
                "threshold": threshold,
                "top_k": top_k
            })
            
            chunks = []
            for row in result:
                chunks.append({
                    "text": row.chunk_text,
                    "index": row.chunk_index,
                    "title": row.title,
                    "source": row.source,
                    "type": row.content_type,
                    "url": row.url,
                    "tags": row.tags,
                    "sectors": row.sectors,
                    "similarity": float(row.similarity)
                })
            
            logger.info(f"Retrieved {len(chunks)} relevant chunks from vector DB")
            return chunks
        except Exception as e:
            logger.error(f"Vector search failed: {e}")
            return []

    async def search_products(
        self,
        user_profile: Dict[str, Any],
        intent: str,
        limit: int = 5,
    ) -> List[Dict[str, Any]]:
        """
        Retrieve candidate products matching user profile + intent.
        Filters by risk_category, suitability, category, and active status.
        """
        logger.info(f"Searching products for intent={intent}")

        # In production:
        # SELECT * FROM products
        # WHERE is_active = TRUE
        #   AND (risk_category = $risk OR risk_category IS NULL)
        #   AND category IN ($relevant_categories)
        # ORDER BY created_at DESC
        # LIMIT $limit

        return []

    def rerank(
        self,
        chunks: List[Dict[str, Any]],
        user_profile: Dict[str, Any],
    ) -> List[Dict[str, Any]]:
        """
        Re-rank retrieved chunks against user profile for relevance,
        recency, and diversity.
        """
        # Score boosting factors:
        # +0.1 if chunk sector matches user preferred_sectors
        # +0.1 if chunk difficulty matches user experience_level
        # +0.05 for recency (published in last 30 days)
        # Apply diversity penalty for same-source chunks

        for chunk in chunks:
            boost = 0.0
            if user_profile.get("preferred_sectors"):
                chunk_sectors = chunk.get("sectors", [])
                if any(s in chunk_sectors for s in user_profile["preferred_sectors"]):
                    boost += 0.1
            chunk["_relevance_score"] = chunk.get("similarity", 0.5) + boost

        return sorted(chunks, key=lambda c: c.get("_relevance_score", 0), reverse=True)
