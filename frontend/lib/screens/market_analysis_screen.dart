import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class MarketAnalysisScreen extends StatelessWidget {
  const MarketAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MARKET ANALYSIS', 
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
            _buildHeadlineCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('SECTOR IMPACT', Icons.pie_chart_outline),
            const SizedBox(height: 16),
            _buildImpactGrid(),
            const SizedBox(height: 32),
            _buildSectionHeader('EXPERT TAKE', Icons.psychology_outlined),
            const SizedBox(height: 16),
            _buildExpertCommentary(),
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

  Widget _buildHeadlineCard() {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      opacity: 0.15,
      isGold: true,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEAB308).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('BUDGET 2024', style: TextStyle(color: Color(0xFFEAB308), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              ),
              const Spacer(),
              const Text('5 MIN READ', style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Focus on Fiscal Consolidation & Infrastructure', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, height: 1.2)),
                    const SizedBox(height: 12),
                    Text('How the new policy shifts will impact your portfolio.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 80,
                height: 80,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 20,
                    sections: [
                      PieChartSectionData(color: const Color(0xFFEAB308), value: 40, radius: 8, showTitle: false),
                      PieChartSectionData(color: const Color(0xFF10B981), value: 30, radius: 8, showTitle: false),
                      PieChartSectionData(color: Colors.white24, value: 30, radius: 8, showTitle: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildAllocationDot('Infra', const Color(0xFFEAB308)),
              const SizedBox(width: 16),
              _buildAllocationDot('Defense', const Color(0xFF10B981)),
              const SizedBox(width: 16),
              _buildAllocationDot('Other', Colors.white24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationDot(String label, Color color) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildImpactGrid() {
    final sectors = [
      {'name': 'INFRASTRUCTURE', 'impact': 'POSITIVE', 'color': const Color(0xFF10B981)},
      {'name': 'DEFENSE', 'impact': 'NEUTRAL', 'color': const Color(0xFF64748B)},
      {'name': 'AGRITECH', 'impact': 'POSITIVE', 'color': const Color(0xFF10B981)},
      {'name': 'CONSUMPTION', 'impact': 'CAUTIOUS', 'color': const Color(0xFFF59E0B)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sectors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return GlassCard(
          padding: const EdgeInsets.all(16),
          opacity: 0.08,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(sectors[index]['name'] as String, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              const SizedBox(height: 10),
              Text(sectors[index]['impact'] as String, style: TextStyle(color: sectors[index]['color'] as Color, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpertCommentary() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage('https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&q=80&w=100'),
              ),
              const SizedBox(width: 12),
              const Text('Anirudh Varma', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('Chief Strategist', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"The market has largely priced in the fiscal consolidation. The real alpha lies in identifying niche infrastructure plays that benefit from the increased capex outlay."',
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
