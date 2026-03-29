import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('ET PRIME SUBSCRIPTION', 
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
            _buildCurrentPlanCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('PREMIUM BENEFITS', Icons.star_outline),
            const SizedBox(height: 16),
            _buildBenefitItem('Expert Portfolio Analysis', 'Exclusive weekly insights from ET Prime editors.', Icons.auto_graph),
            const SizedBox(height: 12),
            _buildBenefitItem('Masterclass Access', 'Unlimited access to LIVE fund manager sessions.', Icons.play_circle_outline),
            const SizedBox(height: 12),
            _buildBenefitItem('Ad-Free Experience', 'Clean, distraction-free reading on all ET platforms.', Icons.block),
            const SizedBox(height: 48),
            _buildUpgradeButton(context),
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

  Widget _buildCurrentPlanCard() {
    return GlassCard(
      padding: const EdgeInsets.all(28),
      opacity: 0.15,
      isGold: true,
      borderRadius: BorderRadius.circular(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ANNUAL PLAN', style: TextStyle(color: Color(0xFFEAB308), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('ET Prime Premium', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('Next billing on March 15, 2025', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String title, String desc, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFEAB308).withOpacity(0.05), shape: BoxShape.circle),
            child: Icon(icon, color: const Color(0xFFEAB308), size: 20),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: const Color(0xFFEAB308).withOpacity(0.1), blurRadius: 20, spreadRadius: -5)
        ]
      ),
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEAB308), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('MANAGE SUBSCRIPTION', style: TextStyle(color: Color(0xFFEAB308), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)),
      ),
    );
  }
}
