import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class DetailedAnalysisScreen extends StatelessWidget {
  final String title;
  final String content;
  final List<Map<String, String>>? details;
  
  const DetailedAnalysisScreen({
    super.key,
    required this.title,
    required this.content,
    this.details,
  });

  @override
  Widget build(BuildContext context) {
    final sections = details ?? _getDefaultSections(title);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(title.toUpperCase(), 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.white)
        ),
      ),
      body: DynamicGradientBackground(
        child: SizedBox.expand(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 80,
              left: 20,
              right: 20,
              bottom: 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  opacity: 0.15,
                  isGold: true,
                  borderRadius: BorderRadius.circular(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.analytics_outlined, color: Colors.white, size: 32),
                      const SizedBox(height: 16),
                      const Text('ET AI ANALYSIS', style: TextStyle(color: Color(0xFFEAB308), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Text(content, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500, height: 1.6)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ...sections.map((section) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _buildSubsection(section['title']!, section['body']!),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getDefaultSections(String title) {
    switch (title.toLowerCase()) {
      case 'risk appetite':
        return [
          {'title': 'YOUR RISK PROFILE', 'body': 'You have a moderately aggressive risk profile. You\'re comfortable with short-term volatility for potential long-term gains, but prefer some downside protection.'},
          {'title': 'PROPOSED ALLOCATION', 'body': '• 60% Equity (Large + Mid Cap)\n• 25% Debt (Corporate Bonds & FDs)\n• 10% Gold / Commodities\n• 5% International Funds'},
          {'title': 'RISK MITIGATION', 'body': 'Diversify across mid-cap and index funds to hedge against sector-specific volatility. Rebalance quarterly to maintain target allocation.'},
        ];
      case 'goals':
        return [
          {'title': 'PRIMARY OBJECTIVES', 'body': '• Build a retirement corpus of ₹1.2 Cr by 2045\n• Purchase a home worth ₹85L by 2028\n• Create an emergency fund of 6 months\' expenses'},
          {'title': 'GOAL-BASED STRATEGY', 'body': 'Short-term goals (< 3 years): Debt funds & FDs\nMedium-term (3-7 years): Balanced hybrid funds\nLong-term (> 7 years): Equity-heavy SIPs'},
          {'title': 'MONTHLY SIP RECOMMENDATION', 'body': 'To achieve your goals, we recommend investing ₹25,000/month across:\n• ₹12,000 → Equity MFs (retirement)\n• ₹8,000 → Balanced fund (home)\n• ₹5,000 → Liquid fund (emergency)'},
        ];
      case 'horizon':
        return [
          {'title': 'INVESTMENT TIMELINE', 'body': 'Your primary investment horizon is long-term (15-20 years), ideal for compounding wealth through equity-heavy portfolios.'},
          {'title': 'TIME-BASED STRATEGY', 'body': '• 2026-2028: Aggressive growth phase — maximize equity exposure\n• 2028-2035: Consolidation phase — shift 20% to debt\n• 2035-2045: Wealth preservation — gradual shift to 50/50 equity-debt'},
          {'title': 'KEY MILESTONES', 'body': '• Year 2 (2028): Home down payment target ₹25L\n• Year 5 (2031): Portfolio value target ₹50L\n• Year 10 (2036): Cross ₹1 Cr milestone\n• Year 20 (2045): Retirement corpus ₹1.2 Cr'},
        ];
      case 'exp. level':
        return [
          {'title': 'YOUR EXPERIENCE', 'body': 'You are an intermediate-level investor with 2-3 years of market exposure. You understand SIPs, mutual fund categories, and basic portfolio diversification.'},
          {'title': 'KNOWLEDGE AREAS', 'body': '✓ Mutual Fund SIPs & lump sum investing\n✓ Tax-saving instruments (80C, 80D)\n✓ Basic equity market awareness\n○ Options & derivatives (learning)\n○ International diversification (new)'},
          {'title': 'RECOMMENDED LEARNING', 'body': '• ET Masterclass: "Advanced Portfolio Rebalancing"\n• Understanding sectoral rotation strategies\n• Introduction to factor-based investing\n• Reading quarterly earnings reports'},
        ];
      case 'equity':
        return [
          {'title': 'MARKET EXPOSURE', 'body': 'Equity funds invest primarily in stocks. They offer high growth potential but come with market volatility.'},
          {'title': 'STRATEGIC ALLOCATION', 'body': '• Large Cap: 50% for stability\n• Mid Cap: 30% for alpha generation\n• Small Cap: 20% for high growth (long-term)'},
          {'title': 'AI RECOMMENDATION', 'body': 'Focus on Flexi-cap funds to allow fund managers to navigate between different market caps based on economic cycles.'},
        ];
      case 'debt':
        return [
          {'title': 'CAPITAL PRESERVATION', 'body': 'Debt funds invest in fixed-income securities like government bonds and corporate debentures.'},
          {'title': 'YIELD & DURATION', 'body': 'Current yields are stable at 7-8%. We recommend short-to-medium duration funds to minimize interest rate risk.'},
          {'title': 'TAX EFFICIENCY', 'body': 'Debt funds are ideal for goals within 3 years. Use them as a hedge against equity volatility.'},
        ];
      case 'hybrid':
        return [
          {'title': 'BALANCED APPROACH', 'body': 'Hybrid funds combine equity and debt to provide a "best of both worlds" experience.'},
          {'title': 'DYNAMIC REBALANCING', 'body': 'These funds automatically shift between asset classes based on market valuations (PE ratios).'},
          {'title': 'IDEAL FOR', 'body': 'First-time investors or medium-term goals (3-5 years) where extreme volatility is undesirable.'},
        ];
      case 'elss':
        return [
          {'title': 'TAX SAVING (80C)', 'body': 'Equity Linked Savings Schemes offer tax deductions up to ₹1.5L under Section 80C.'},
          {'title': 'LOCK-IN PERIOD', 'body': 'ELSS has the shortest lock-in (3 years) among all 80C options (PPF: 15yr, NSC: 5yr).'},
          {'title': 'WEALTH CREATION', 'body': 'Historically, ELSS has outperformed other tax-saving instruments due to its 100% equity exposure.'},
        ];
      default:
        return [
          {'title': 'ANALYSIS', 'body': 'Based on your $title, we recommend a diversified approach to balance growth and safety.'},
          {'title': 'NEXT STEPS', 'body': 'Continue your conversation with the ET NEXUS AI to refine your strategy.'},
        ];
    }
  }

  Widget _buildSubsection(String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(20),
          opacity: 0.08,
          borderRadius: BorderRadius.circular(20),
          child: Text(body, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.6)),
        ),
      ],
    );
  }
}
