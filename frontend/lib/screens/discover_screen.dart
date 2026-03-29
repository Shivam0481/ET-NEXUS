import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';
import 'mutual_funds_screen.dart';
import 'equity_screen.dart';
import 'tax_saving_screen.dart';
import 'insurance_screen.dart';
import 'masterclass_screen.dart';
import 'market_analysis_screen.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('DISCOVER', 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 2.0,
            color: Colors.white,
          )
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white70, size: 20), 
            onPressed: () {}
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DynamicGradientBackground(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            bottom: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('TRENDING ON ET', Icons.bolt_outlined),
              const SizedBox(height: 16),
              _buildGlassFeaturedCard(
                context, 
                'Market Analysis: Budget 2024 Impact', 
                'ET PRIME • 5 min read', 
                Icons.trending_up, 
                const Color(0xFFEAB308),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketAnalysisScreen())),
              ),
              const SizedBox(height: 12),
              _buildGlassFeaturedCard(
                context, 
                'Top 5 High-Yield SIPs', 
                'ET WEALTH • Expert Pick', 
                Icons.account_balance_wallet_outlined, 
                const Color(0xFF10B981),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MutualFundsScreen())),
              ),

              const SizedBox(height: 32),
              
              _buildSectionHeader('FINANCIAL CATEGORIES', Icons.category_outlined),
              const SizedBox(height: 16),
              _buildCategoryGrid(),

              const SizedBox(height: 32),
              
              _buildSectionHeader('LATEST MASTERCLASSES', Icons.play_circle_outline),
              const SizedBox(height: 16),
              _buildMasterclassCard(
                context, 
                'Portfolio Alpha Masterclass', 
                'Learn advanced strategies from India\'s top fund managers', 
                'Tomorrow • 6:00 PM'
              ),
              const SizedBox(height: 100), // Space for bottom bar
            ],
          ),
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
          style: TextStyle(
            fontSize: 10, 
            fontWeight: FontWeight.w900, 
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 1.5
          )
        ),
      ],
    );
  }

  Widget _buildGlassFeaturedCard(BuildContext context, String title, String subtitle, IconData icon, Color accentColor, {required VoidCallback onTap}) {
    return GlassCard(
      padding: EdgeInsets.zero,
      opacity: 0.1,
      isGold: accentColor == const Color(0xFFEAB308),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withOpacity(0.2)),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, 
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white, height: 1.3)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, 
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: Colors.white.withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Mutual Funds', 'icon': Icons.pie_chart_outline},
      {'name': 'Equity', 'icon': Icons.show_chart},
      {'name': 'Tax Saving', 'icon': Icons.receipt_long_outlined},
      {'name': 'Insurance', 'icon': Icons.shield_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return GlassCard(
          padding: EdgeInsets.zero,
          opacity: 0.08,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {
              Widget screen;
              switch (categories[index]['name'] as String) {
                case 'Mutual Funds': screen = const MutualFundsScreen(); break;
                case 'Equity': screen = const EquityScreen(); break;
                case 'Tax Saving': screen = const TaxSavingScreen(); break;
                case 'Insurance': screen = const InsuranceScreen(); break;
                default: screen = const MutualFundsScreen();
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
            },
            borderRadius: BorderRadius.circular(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(categories[index]['icon'] as IconData, size: 18, color: const Color(0xFFEAB308).withOpacity(0.7)),
                const SizedBox(width: 10),
                Text(categories[index]['name'] as String, 
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white70)
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMasterclassCard(BuildContext context, String title, String desc, String time) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      opacity: 0.15,
      isGold: true,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('LIVE', 
                  style: TextStyle(color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)
                ),
              ),
              Text('ET LEARN • PREMIUM', 
                style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.bold)
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
          const SizedBox(height: 8),
          Text(desc, 
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4)
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: const Color(0xFFEAB308).withOpacity(0.6)),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFEAB308).withOpacity(0.3), blurRadius: 15, spreadRadius: -5)
                  ]
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MasterclassScreen())),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEAB308),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text('JOIN SESSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
