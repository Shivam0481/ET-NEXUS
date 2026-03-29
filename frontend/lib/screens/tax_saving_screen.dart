import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class TaxSavingScreen extends StatelessWidget {
  const TaxSavingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('TAX SAVING PLANNER', 
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
            _buildTaxLimitCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('80C INVESTMENTS', Icons.security_outlined),
            const SizedBox(height: 16),
            _buildTaxInvestmentList(),
            const SizedBox(height: 32),
            _buildSectionHeader('HEALTH INSURANCE (80D)', Icons.medical_services_outlined),
            const SizedBox(height: 16),
            _buildInsuranceCard(),
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

  Widget _buildTaxLimitCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      opacity: 0.15,
      isGold: true,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Remaining 80C Limit', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text('₹45,000', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    SizedBox(height: 20),
                    Text('₹1.05L Invested of ₹1.5L', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(color: const Color(0xFFEAB308), value: 70, radius: 10, showTitle: false),
                      PieChartSectionData(color: Colors.white.withOpacity(0.1), value: 30, radius: 10, showTitle: false),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('ELSS', '₹45,000', const Color(0xFFEAB308)),
          const SizedBox(height: 12),
          _buildDetailRow('PPF', '₹30,000', const Color(0xFF06B6D4)),
          const SizedBox(height: 12),
          _buildDetailRow('Insurance', '₹30,000', const Color(0xFF8B5CF6)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildTaxInvestmentList() {
    final instruments = [
      {'name': 'ELSS Mutual Funds', 'amount': '₹45,000', 'status': 'HIGH YIELD'},
      {'name': 'Public Provident Fund (PPF)', 'amount': '₹30,000', 'status': 'SECURE'},
      {'name': 'Life Insurance Premium', 'amount': '₹30,000', 'status': 'PROTECT'},
    ];

    return Column(
      children: instruments.map((inst) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          opacity: 0.1,
          borderRadius: BorderRadius.circular(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(inst['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(inst['status']!, style: TextStyle(color: const Color(0xFFEAB308).withOpacity(0.5), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  ],
                ),
              ),
              Text(inst['amount']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildInsuranceCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      opacity: 0.08,
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Icon(Icons.favorite_outline, color: Color(0xFF10B981), size: 24)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Family Floater Policy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 4),
                Text('Save up to ₹25,000 additional tax', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
