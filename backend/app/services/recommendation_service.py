"""
Recommendation Service — Matches user profile to products/content
with explainability and confidence scoring.
"""
import logging
from typing import Dict, Any, List, Optional

logger = logging.getLogger("et_concierge.recommendation")


class RecommendationService:
    """Generates and manages personalized recommendations."""

    def score_product(
        self,
        product: Dict[str, Any],
        user_profile: Dict[str, Any],
    ) -> Dict[str, Any]:
        """
        Score a product against user profile.
        Returns product with confidence_score and relevance_factors.
        """
        score = 0.0
        factors = []

        # Risk alignment
        user_risk = user_profile.get("risk_appetite", "").lower()
        product_risk = (product.get("risk_category") or "").lower()
        if user_risk and product_risk and user_risk == product_risk:
            score += 0.3
            factors.append("risk_aligned")

        # Goal matching
        user_goals = user_profile.get("financial_goals", [])
        suitability = product.get("suitability", {})
        product_goals = suitability.get("goals", [])
        matching_goals = set(user_goals) & set(product_goals)
        if matching_goals:
            score += 0.25 * len(matching_goals)
            factors.extend([f"goal_match:{g}" for g in matching_goals])

        # Experience fit
        user_exp = user_profile.get("experience_level", "").lower()
        min_exp = suitability.get("min_experience", "").lower()
        exp_levels = {"beginner": 1, "intermediate": 2, "advanced": 3}
        if user_exp and min_exp:
            if exp_levels.get(user_exp, 0) >= exp_levels.get(min_exp, 0):
                score += 0.15
                factors.append("experience_fit")

        # Horizon matching
        user_horizon = user_profile.get("investment_horizon", "").lower()
        product_horizon = suitability.get("horizon", "").lower()
        if user_horizon and product_horizon and user_horizon == product_horizon:
            score += 0.2
            factors.append(f"horizon_match:{user_horizon}")

        # ET Prime member bonus
        if user_profile.get("et_prime_member") and product.get("category") == "et_prime":
            score += 0.1
            factors.append("et_prime_member")

        return {
            **product,
            "confidence_score": min(round(score, 2), 1.0),
            "relevance_factors": factors,
        }

    def generate_explanation(
        self,
        product: Dict[str, Any],
        user_profile: Dict[str, Any],
        factors: List[str],
    ) -> str:
        """Generate a human-readable explanation for why this recommendation fits."""
        parts = []

        if "risk_aligned" in factors:
            parts.append(f"matches your {user_profile.get('risk_appetite', 'moderate')} risk appetite")

        goal_factors = [f for f in factors if f.startswith("goal_match:")]
        if goal_factors:
            goals = [f.split(":")[1].replace("_", " ") for f in goal_factors]
            parts.append(f"aligns with your {', '.join(goals)} goal{'s' if len(goals) > 1 else ''}")

        if "experience_fit" in factors:
            parts.append(f"suitable for your {user_profile.get('experience_level', 'beginner')}-level experience")

        horizon_factors = [f for f in factors if f.startswith("horizon_match:")]
        if horizon_factors:
            horizon = horizon_factors[0].split(":")[1].replace("_", " ")
            parts.append(f"fits your {horizon} investment horizon")

        if not parts:
            return f"{product.get('name', 'This option')} could be a good fit based on your current profile."

        explanation = f"{product.get('name', 'This option')} — " + ", ".join(parts) + "."
        return explanation.capitalize()

    def filter_and_rank(
        self,
        products: List[Dict[str, Any]],
        user_profile: Dict[str, Any],
        min_confidence: float = 0.2,
        max_results: int = 5,
    ) -> List[Dict[str, Any]]:
        """Score, filter, and rank products for a user."""
        scored = [self.score_product(p, user_profile) for p in products]
        filtered = [p for p in scored if p["confidence_score"] >= min_confidence]
        ranked = sorted(filtered, key=lambda p: p["confidence_score"], reverse=True)

        # Add explanations
        for item in ranked[:max_results]:
            item["explanation"] = self.generate_explanation(
                item, user_profile, item["relevance_factors"]
            )

        return ranked[:max_results]
