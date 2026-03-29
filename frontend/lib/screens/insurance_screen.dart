import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('INSURANCE ADVISOR', 
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2.0, color: Colors.white)
        ),
      ),
      body: DynamicGradientBackground(
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          children: [
            _buildSafetyScoreCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('PROTECTION GAP', Icons.warning_amber_rounded),
            const SizedBox(height: 16),
            _buildProtectionGapCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('RECOMMENDED POLICIES', Icons.verified_user_outlined),
            const SizedBox(height: 16),
            _buildInsuranceOfferCard('Term Life Insurance', '₹2 Cr Coverage • ₹1,200/mo', Icons.family_restroom),
            const SizedBox(height: 12),
            _buildInsuranceOfferCard('Critical Illness Rider', '₹50 Lakh Coverage • ₹450/mo', Icons.medical_services_outlined),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFEAB308)),
        const SizedBox(width: 10),
        Text(title, 
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.4), letterSpacing: 1.5)
        ),
      ],
    );
  }

  Widget _buildSafetyScoreCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      opacity: 0.15,
      isGold: true,
      borderRadius: BorderRadius.circular(28),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Safety Score', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('72 / 100', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          SizedBox(height: 12),
          Text('Moderately protected against risks.', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProtectionGapCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFEF4444).withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.privacy_tip_outlined, color: Color(0xFFEF4444), size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Under-insured: ₹1.2 Cr', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Your current life coverage is insufficient for your liabilities.', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.white38, fontWeight: FontWeight.bold, fontSize: 10);
                        switch (value.toInt()) {
                          case 0: return const Text('CURRENT', style: style);
                          case 1: return const Text('IDEAL', style: style);
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0.8, color: Colors.white10, width: 40, borderRadius: BorderRadius.circular(6))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 2.0, color: const Color(0xFFEAB308), width: 40, borderRadius: BorderRadius.circular(6))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceOfferCard(String title, String subtitle, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      opacity: 0.08,
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFEAB308).withOpacity(0.7), size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 16, color: Colors.white.withOpacity(0.1)),
        ],
      ),
    );
  }
}
