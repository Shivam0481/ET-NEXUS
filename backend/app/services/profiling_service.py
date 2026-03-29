"""
Profiling Service — Manages the progressive financial profiling pipeline.
Determines profiling stage, merges profile updates with confidence gating.
"""
import logging
from typing import Dict, Any, Optional, List

logger = logging.getLogger("et_concierge.profiling")

PROFILING_STAGES = ["intro", "goals", "risk", "portfolio", "complete"]


class ProfilingService:
    """Manages the 5-stage conversational profiling flow."""

    def determine_stage(self, user_insights: Optional[Dict[str, Any]]) -> str:
        """Determine current profiling stage based on filled fields."""
        if not user_insights:
            return "intro"

        has_goals = bool(user_insights.get("financial_goals"))
        has_risk = bool(user_insights.get("risk_appetite"))
        has_portfolio = bool(user_insights.get("existing_portfolio")) and bool(user_insights.get("experience_level"))

        if user_insights.get("profiling_complete"):
            return "complete"
        if has_portfolio:
            return "complete"
        if has_risk:
            return "portfolio"
        if has_goals:
            return "risk"
        return "goals"

    def merge_profile_updates(
        self,
        existing: Dict[str, Any],
        updates: Dict[str, Any],
        existing_confidence: Dict[str, float],
    ) -> Dict[str, Any]:
        """
        Merge new profile signals into existing insights.
        Only overwrites if new confidence > existing confidence.
        """
        merged = existing.copy()
        new_confidence = existing_confidence.copy()

        if updates is None:
            return merged

        # Risk appetite
        if updates.get("risk_appetite"):
            ra = updates["risk_appetite"]
            new_conf = ra.get("confidence", 0.5) if isinstance(ra, dict) else 0.5
            old_conf = existing_confidence.get("risk_appetite", 0.0)

            if new_conf > old_conf:
                merged["risk_appetite"] = ra.get("value", ra) if isinstance(ra, dict) else ra
                new_confidence["risk_appetite"] = new_conf
                logger.info(f"Updated risk_appetite: {merged['risk_appetite']} (conf: {new_conf})")

        # Financial goals (additive, not replacement)
        if updates.get("financial_goals"):
            existing_goals = set(existing.get("financial_goals", []))
            new_goals = set(updates["financial_goals"])
            merged["financial_goals"] = list(existing_goals | new_goals)

        # Simple string fields
        for field in ["investment_horizon", "experience_level"]:
            if updates.get(field):
                merged[field] = updates[field]

        merged["_confidence_scores"] = new_confidence
        return merged

    def get_followup_questions(self, stage: str, profile: Dict[str, Any]) -> List[str]:
        """Return contextual follow-up questions for the current stage."""
        questions = {
            "intro": [
                "I'd love to help you make smarter financial decisions. What's been on your mind when it comes to money or investments?"
            ],
            "goals": [
                "What are you looking to achieve financially? For example — retirement planning, building wealth, saving for a big purchase, or your child's education?"
            ],
            "risk": [
                "How comfortable are you with market fluctuations? Would you say you're conservative (prefer stability), moderate (some ups and downs are fine), or aggressive (willing to take risks for higher returns)?"
            ],
            "portfolio": [
                "Do you currently invest in anything — like mutual funds, stocks, fixed deposits, or gold? And how would you rate your investing experience — beginner, intermediate, or advanced?"
            ],
        }
        return questions.get(stage, [])
