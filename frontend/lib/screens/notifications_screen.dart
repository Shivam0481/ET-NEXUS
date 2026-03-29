import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('NOTIFICATIONS', 
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
            _buildNotificationItem('Market Update', 'Nifty 50 touched an all-time high of 22,040 today. Review your portfolio allocations.', '2h ago', Icons.trending_up, const Color(0xFF10B981)),
            _buildNotificationItem('Portfolio Alert', 'Your mutual fund SIP for Quant Small Cap was processed successfully.', '5h ago', Icons.account_balance_wallet_outlined, const Color(0xFFEAB308)),
            _buildNotificationItem('Tax Deadline', 'Only 3 days left to complete your 80C investments for FY 2023-24.', '1d ago', Icons.timer_outlined, const Color(0xFFEF4444)),
            _buildNotificationItem('Security Alert', 'New login detected from a Chrome browser on Windows.', '2d ago', Icons.shield_outlined, const Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, String time, IconData icon, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        opacity: 0.1,
        borderRadius: BorderRadius.circular(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: accentColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      Text(time, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(message, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
