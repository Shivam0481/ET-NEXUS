"""
LLM Service — Wraps OpenAI API calls with structured JSON output parsing.
"""
import json
import logging
from typing import Optional, Dict, Any, List

from openai import AsyncOpenAI

from app.core.config import settings
from app.schemas.chat_schema import RagResponse

logger = logging.getLogger("et_concierge.llm")

# Singleton client
_client: Optional[AsyncOpenAI] = None


def _get_client() -> AsyncOpenAI:
    global _client
    if _client is None:
        _client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)
    return _client


async def call_llm(
    system_prompt: str,
    user_message: str,
    temperature: float = 0.7,
    max_tokens: int = 2000,
) -> Dict[str, Any]:
    """
    Call OpenAI and parse the strict JSON response.
    Returns raw dict; caller validates with Pydantic.
    """
    client = _get_client()

    try:
        response = await client.chat.completions.create(
            model=settings.OPENAI_MODEL,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message},
            ],
            temperature=temperature,
            max_tokens=max_tokens,
            response_format={"type": "json_object"},
        )

        content = response.choices[0].message.content.strip()
        token_usage = {
            "prompt": response.usage.prompt_tokens,
            "completion": response.usage.completion_tokens,
            "total": response.usage.total_tokens,
        }

        parsed = json.loads(content)
        parsed["_token_usage"] = token_usage
        parsed["_model"] = response.model
        return parsed

    except json.JSONDecodeError as e:
        logger.error(f"LLM returned non-JSON: {e}")
        return _fallback_response("I had trouble processing that. Could you rephrase?")
    except Exception as e:
        logger.error(f"LLM call failed: {e}")
        return _fallback_response("I'm having a brief technical issue. Please try again in a moment.")


async def generate_embeddings(texts: List[str]) -> List[List[float]]:
    """Generate embeddings for a list of texts using OpenAI."""
    client = _get_client()
    response = await client.embeddings.create(
        model=settings.OPENAI_EMBEDDING_MODEL,
        input=texts,
    )
    return [item.embedding for item in response.data]


def _fallback_response(message: str) -> Dict[str, Any]:
    return {
        "message": {
            "content": message,
            "intent": "general_chat",
            "entities": [],
        },
        "profile_updates": None,
        "recommendations": [],
        "next_profiling_stage": "intro",
    }
