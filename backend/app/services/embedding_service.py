"""
Embedding Service — Generates and manages text embeddings for RAG retrieval.
"""
import logging
from typing import List, Optional

from app.services.llm_service import generate_embeddings

logger = logging.getLogger("et_concierge.embedding")


class EmbeddingService:
    """Handles text-to-vector conversion for the RAG pipeline."""

    async def embed_query(self, text: str) -> List[float]:
        """Embed a single query string."""
        embeddings = await generate_embeddings([text])
        return embeddings[0]

    async def embed_batch(self, texts: List[str]) -> List[List[float]]:
        """Embed a batch of texts (for content ingestion)."""
        if not texts:
            return []
        # OpenAI supports batches up to ~2048 texts
        return await generate_embeddings(texts)

    @staticmethod
    def cosine_similarity(a: List[float], b: List[float]) -> float:
        """Compute cosine similarity between two vectors."""
        import numpy as np
        a_np = np.array(a)
        b_np = np.array(b)
        return float(np.dot(a_np, b_np) / (np.linalg.norm(a_np) * np.linalg.norm(b_np)))
