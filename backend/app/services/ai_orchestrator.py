"""
AI Orchestrator — The heart of the ET Financial Concierge.
Coordinates the full RAG pipeline:
  1. Intent Detection & Entity Extraction
  2. Context Assembly (user profile + history + behavioral signals)
  3. Semantic Retrieval (content_chunks via pgvector)
  4. Re-ranking
  5. Prompt Assembly (Jinja2 template)
  6. LLM Generation (OpenAI GPT-4)
  7. Post-processing (profile updates, recommendation storage)
"""
import json
import logging
import uuid
from pathlib import Path
from typing import Dict, Any, Optional, List

from jinja2 import Template
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from datetime import datetime, timezone

from app.core.config import settings
from app.schemas.chat_schema import RagResponse, ProfileUpdates
from app.services.llm_service import call_llm
from app.services.embedding_service import EmbeddingService
from app.services.retrieval_service import RetrievalService
from app.services.profiling_service import ProfilingService
from app.services.recommendation_service import RecommendationService
from app.models.database import UserInsight, Conversation, Message

logger = logging.getLogger("et_concierge.orchestrator")

# Load system prompt template
PROMPT_DIR = Path(__file__).parent.parent / "prompts"
with open(PROMPT_DIR / "system_prompt.txt", "r") as f:
    SYSTEM_PROMPT_TEMPLATE = Template(f.read())

def utcnow():
    return datetime.now(timezone.utc)

class AIOrchestrator:
    """
    Main entry point for the AI pipeline with persistent DB storage.
    """

    def __init__(self):
        self.embedding_service = EmbeddingService()
        self.retrieval_service = RetrievalService()
        self.profiling_service = ProfilingService()
        self.recommendation_service = RecommendationService()

    async def process_message(
        self,
        conversation_id: Optional[str],
        user_input: str,
        db: AsyncSession,
        context: Optional[Dict[str, Any]] = None,
        user_id: Optional[str] = None,
    ) -> RagResponse:
        """
        Full 7-step RAG pipeline execution with DB persistence.
        """
        # ── Step 0: Resolve or create conversation ──
        # Handle Guest Mode if no user_id is provided
        is_guest = False
        if not user_id:
            user_id = settings.GUEST_USER_ID
            is_guest = True

        # Ensure User and Insights exist (especially for Guests)
        from app.models.database import User, UserInsight
        user_result = await db.execute(select(User).where(User.id == user_id))
        user_obj = user_result.scalars().first()
        
        if not user_obj and is_guest:
            # Create a permanent Guest user for this environment
            user_obj = User(
                id=user_id,
                email="guest@etconcierge.ai",
                full_name="Guest User",
                hashed_password="n/a",
                is_active=True
            )
            db.add(user_obj)
            await db.flush()

            # Also create guest insights
            guest_insight = UserInsight(user_id=user_id)
            db.add(guest_insight)
            await db.flush()

        # Find or create conversation
        if conversation_id:
            try:
                result = await db.execute(
                    select(Conversation)
                    .where(Conversation.id == conversation_id, Conversation.user_id == user_id)
                )
                conv = result.scalars().first()
            except Exception:
                conv = None
        else:
            conv = None

        if not conv:
            conv = Conversation(user_id=user_id, profiling_stage="intro")
            db.add(conv)
            await db.flush()
            conversation_id = str(conv.id)

        # Load user insights
        insight_result = await db.execute(select(UserInsight).where(UserInsight.user_id == user_id))
        insight = insight_result.scalars().first()
        user_profile = self._insight_to_profile_dict(insight)

        # Load history
        history_result = await db.execute(
            select(Message)
            .where(Message.conversation_id == conv.id)
            .order_by(Message.created_at.desc())
            .limit(settings.MAX_CONVERSATION_HISTORY)
        )
        history_msgs = history_result.scalars().all()
        conversation_history = [{"role": m.role, "content": m.content} for m in reversed(history_msgs)]

        # ── Step 1 & 2: Log User Message ──
        user_msg = Message(
            conversation_id=conv.id,
            role="user",
            content=user_input
        )
        db.add(user_msg)
        conversation_history.append({"role": "user", "content": user_input})

        # ── Step 3: Semantic Retrieval ──
        retrieved_content = []
        try:
            if settings.OPENAI_API_KEY:
                query_embedding = await self.embedding_service.embed_query(user_input)
                retrieved_content = await self.retrieval_service.search(query_embedding)
                retrieved_content = self.retrieval_service.rerank(retrieved_content, user_profile)
        except Exception as e:
            logger.warning(f"Retrieval failed (non-fatal): {e}")

        # ── Step 4: Product retrieval ──
        candidate_products = []
        try:
            candidate_products = await self.retrieval_service.search_products(
                user_profile, intent="general"
            )
        except Exception as e:
            logger.warning(f"Product retrieval failed (non-fatal): {e}")

        # ── Step 5: Prompt Assembly ──
        system_prompt = SYSTEM_PROMPT_TEMPLATE.render(
            user_profile=json.dumps(user_profile, indent=2) if user_profile else "No profile yet.",
            conversation_history=self._format_history(conversation_history),
            retrieved_content=json.dumps(retrieved_content, indent=2) if retrieved_content else "No relevant content.",
            candidate_products=json.dumps(candidate_products, indent=2) if candidate_products else "No products.",
            user_events="No behavioral signals.",
            profiling_stage=conv.profiling_stage,
            current_message=user_input,
        )

        # ── Step 6: LLM Generation ──
        if settings.OPENAI_API_KEY:
            raw_response = await call_llm(system_prompt, user_input)
        else:
            raw_response = self._demo_response(user_input, conv.profiling_stage, user_profile)

        # ── Step 7: Post-processing & Persistence ──
        try:
            token_usage = raw_response.get("_token_usage", {})
            rag_response = RagResponse(**raw_response)
        except Exception as e:
            logger.error(f"Failed to parse LLM response: {e}")
            rag_response = self._fallback_rag_response(conv.profiling_stage)

        # Save Assistant Message
        assistant_msg = Message(
            conversation_id=conv.id,
            role="assistant",
            content=rag_response.message.content,
            intent=rag_response.message.intent,
            entities=[e.model_dump() for e in rag_response.message.entities],
            token_usage=token_usage
        )
        db.add(assistant_msg)

        # Update profiling stage and counts
        conv.profiling_stage = rag_response.next_profiling_stage or conv.profiling_stage
        conv.message_count += 2
        conv.updated_at = utcnow()

        # Merge profile updates
        if rag_response.profile_updates and insight:
            updated_insights = self.profiling_service.merge_profile_updates(
                user_profile,
                rag_response.profile_updates.model_dump(),
                user_profile.get("_confidence_scores", {}),
            )
            self._update_insight_model(insight, updated_insights)

        await db.commit()
        
        # Attach conv_id for the router
        rag_response.conversation_id = str(conv.id)
        return rag_response

    def _insight_to_profile_dict(self, insight: Optional[UserInsight]) -> Dict[str, Any]:
        if not insight: return {}
        return {
            "risk_appetite": insight.risk_appetite,
            "financial_goals": insight.financial_goals,
            "investment_horizon": insight.investment_horizon,
            "experience_level": insight.experience_level,
            "income_bracket": insight.income_bracket,
            "preferred_sectors": insight.preferred_sectors,
            "existing_portfolio": insight.existing_portfolio,
            "_confidence_scores": insight.confidence_scores or {},
        }

    def _update_insight_model(self, model: UserInsight, profile: Dict[str, Any]):
        for key in ["risk_appetite", "financial_goals", "investment_horizon", "experience_level", "income_bracket", "preferred_sectors", "existing_portfolio"]:
            if key in profile:
                setattr(model, key, profile[key])
        model.confidence_scores = profile.get("_confidence_scores", {})
        if profile.get("profiling_complete"):
            model.profiling_complete = True

    def _fallback_rag_response(self, stage: str) -> RagResponse:
         return RagResponse(
            message={
                "content": "I'd be happy to help! Could you tell me more?",
                "intent": "general_chat",
                "entities": [],
            },
            recommendations=[],
            next_profiling_stage=stage,
        )

    def _format_history(self, history: List[Dict[str, str]]) -> str:
        if not history: return "No previous messages."
        return "\n".join([f"[{m['role'].upper()}]: {m['content']}" for m in history])

    def _demo_response_as_rag_response(self, user_input: str, stage: str, profile: Dict[str, Any]) -> RagResponse:
        raw = self._demo_response(user_input, stage, profile)
        return RagResponse(**raw)

    def _demo_response(
        self, user_input: str, stage: str, profile: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Intelligent demo mode when no OpenAI API key is configured.
        Detects question intent and provides topic-specific answers.
        """
        user_lower = user_input.lower()

        # ── 1. Intent Detection ──
        intent = "general_chat"
        entities = []

        # Knowledge Base for Demo Mode
        knowledge_base = {
            "sip": "Systematic Investment Plan (SIP) is a method where you invest a fixed amount regularly in mutual funds. For a {{risk}} profile like yours, I'd suggest starting with a {{fund}} which has shown consistent performance.",
            "mutual fund": "Mutual funds pool money from many investors to invest in stocks, bonds, or other securities. Based on your {{risk}} appetite, {{fund_type}} would be a great starting point for your {{goal}} goal.",
            "stock": "Investing in individual stocks requires research. For now, since you're at the {{experience}} level, I recommend focusing on Blue-chip stocks or Index funds which track the top 50 companies in India.",
            "tax": "To save tax under Section 80C, you can explore ELSS (Equity Linked Saving Schemes) which have the shortest lock-in period of 3 years and offer potential for high returns.",
            "banking": "Digital banking in India has evolved rapidly with UPI. For your wealth management, choosing a bank with a strong mobile app and personalized investment options like HDFC or ICICI is advisable.",
            "retirement": "Retirement planning is about building a corpus that generates inflation-adjusted income. Starting early with a mix of NPS, EPF, and Diversified Equity Funds is key to hitting your goal.",
            "insurance": "Term insurance is the purest form of life insurance. It provides high cover at a low premium. For health, ensure you have a base plan of at least ₹5-10 lakh for a family of four.",
            "market": "The Indian markets are showing strong growth potential driven by domestic demand and infrastructure spending. It's a good time to stay invested for the long term.",
        }

        # Detect specific keywords and provide answers
        special_answer = None
        for key, template in knowledge_base.items():
            if key in user_lower:
                intent = "investment_query" if key != "banking" else "product_discovery"
                
                # Dynamic template filling
                risk = str(profile.get("risk_appetite", "moderate")).lower()
                experience = str(profile.get("experience_level", "beginner")).lower()
                goal = str(profile.get("financial_goals", ["wealth creation"])[0]).replace("_", " ")
                
                fund = "SBI Bluechip Fund" if risk == "conservative" else "Quant Small Cap Fund" if risk == "aggressive" else "Parag Parikh Flexi Cap Fund"
                fund_type = "Large Cap Funds" if risk == "conservative" else "Small/Mid Cap Funds" if risk == "aggressive" else "Flexi Cap Funds"
                
                special_answer = template.replace("{{risk}}", risk).replace("{{fund}}", fund).replace("{{fund_type}}", fund_type).replace("{{goal}}", goal).replace("{{experience}}", experience)
                break

        # Extract entities (amount, goals)
        import re
        amount_match = re.search(r'₹?\s*([\d,]+(?:\.\d+)?)\s*(?:k|lakh|lac|cr|crore)?', user_lower)
        if amount_match:
            entities.append({"type": "amount", "value": amount_match.group(0).strip()})

        # ── 2. Response Logic ──
        profile_updates: Dict[str, Any] = {}
        next_stage_val = stage
        recommendations: List[Dict[str, Any]] = []

        if special_answer:
            content = special_answer + "\n\nWould you like to know more about this, or should we continue with your profile?"
        elif stage == "intro":
            content = (
                "Welcome to the ET Financial Concierge! 🏦 I'm here to help you navigate "
                "the world of investments and financial planning — tailored just for you.\n\n"
                "To get started, could you share what financial goals are most important to you right now? "
                "For example — planning for retirement, building wealth, or saving for tax?"
            )
            next_stage_val = "goals"
        elif stage == "goals":
            content = "That's a great goal! Now, what is your risk appetite? Are you Conservative, Moderate, or Aggressive?"
            next_stage_val = "risk"
        elif stage == "risk":
            content = "Got it. Finally, what's your investment experience level? Are you a Beginner, Intermediate, or Advanced?"
            next_stage_val = "portfolio"
        else:
            content = "I'm here to help! Feel free to ask about SIPs, Stocks, Mutual Funds, or Tax Saving strategies."
            next_stage_val = "complete"

        # Generate some recommendations if applicable
        if intent != "general_chat" or stage == "portfolio":
            risk_val = str(profile.get("risk_appetite", "moderate"))
            goals_list = profile.get("financial_goals", ["wealth_creation"])
            recommendations = self._generate_demo_recommendations(risk_val, goals_list, str(profile.get("experience_level", "beginner")))

        return {
            "message": {
                "content": content,
                "intent": intent,
                "entities": entities,
            },
            "profile_updates": profile_updates if profile_updates else None,
            "recommendations": recommendations,
            "next_profiling_stage": next_stage_val,
        }

    def _generate_demo_recommendations(
        self, risk: str, goals: List[str], experience: str
    ) -> List[Dict[str, Any]]:
        """Generate realistic demo recommendations based on user profile."""
        recs = []

        goal_set = set(goals)

        if risk == "conservative":
            if "retirement" in goal_set or "wealth_creation" in goal_set:
                recs.append({
                    "title": "HDFC Balanced Advantage Fund — Direct Growth",
                    "type": "product",
                    "entity_id": "prod_hdfc_bal",
                    "explanation": f"This fund dynamically balances equity and debt, suiting your conservative approach and {', '.join([g.replace('_',' ') for g in goals])} goal. Its 3-year return of ~12% comes with lower volatility.",
                    "confidence_score": 0.87,
                    "relevance_factors": ["risk_aligned", f"goal_match:{goals[0]}", "experience_fit"],
                })
            recs.append({
                "title": "ET Masterclass: Smart Fixed-Income Strategies",
                "type": "content",
                "entity_id": "content_fi_master",
                "explanation": f"Designed for {experience} investors who prefer stability. Covers debt funds, FDs, and bonds — perfect for your conservative style.",
                "confidence_score": 0.79,
                "relevance_factors": ["risk_aligned", "experience_fit"],
            })
        elif risk == "moderate":
            if "retirement" in goal_set:
                recs.append({
                    "title": "SBI Bluechip Fund — Direct Growth",
                    "type": "product",
                    "entity_id": "prod_sbi_blue",
                    "explanation": f"This large-cap fund aligns with your moderate risk appetite and retirement goal. 5-year CAGR of ~14.2% with a low expense ratio — ideal for a long-term SIP.",
                    "confidence_score": 0.89,
                    "relevance_factors": ["risk_aligned", "goal_match:retirement", "horizon_match:long_term"],
                })
            recs.append({
                "title": "Parag Parikh Flexi Cap Fund — Direct Growth",
                "type": "product",
                "entity_id": "prod_ppfas",
                "explanation": f"A diversified equity fund with global exposure that matches your moderate risk tolerance. Strong track record and low turnover.",
                "confidence_score": 0.82,
                "relevance_factors": ["risk_aligned", "goal_match:wealth_creation"],
            })
        elif risk == "aggressive":
            recs.append({
                "title": "Quant Small Cap Fund — Direct Growth",
                "type": "product",
                "entity_id": "prod_quant_sc",
                "explanation": f"High-growth small-cap fund for your aggressive risk style. Delivered ~28% CAGR over 3 years — higher risk but strong momentum.",
                "confidence_score": 0.84,
                "relevance_factors": ["risk_aligned", "goal_match:wealth_creation"],
            })
            recs.append({
                "title": "ET Prime: Top Sectoral Picks for 2024",
                "type": "content",
                "entity_id": "content_sectoral",
                "explanation": f"In-depth analysis of high-growth sectors — ideal reading for an aggressive, {experience}-level investor like you.",
                "confidence_score": 0.76,
                "relevance_factors": ["risk_aligned", "experience_fit"],
            })

        # Always add an event recommendation if profile is complete
        recs.append({
            "title": "ET Wealth Conference 2024",
            "type": "event",
            "entity_id": "event_et_wealth",
            "explanation": f"A flagship ET event featuring top fund managers and financial planners — great for networking and deepening your investment knowledge.",
            "confidence_score": 0.71,
            "relevance_factors": ["engagement_opportunity", "experience_fit"],
        })

        return recs
