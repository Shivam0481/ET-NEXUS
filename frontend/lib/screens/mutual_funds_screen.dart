import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';
import 'equity_screen.dart';
import 'tax_saving_screen.dart';
import 'detailed_analysis_screen.dart';

class MutualFundsScreen extends StatelessWidget {
  const MutualFundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MUTUAL FUNDS', 
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
            _buildPortfolioCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('DIVERSIFY YOUR WEALTH', Icons.explore_outlined),
            const SizedBox(height: 16),
            _buildInvestBridgeCards(context),
            const SizedBox(height: 32),
            _buildSectionHeader('TOP PERFORMING FUNDS', Icons.workspace_premium_outlined),
            const SizedBox(height: 16),
            _buildFundList(),
            const SizedBox(height: 32),
            _buildSectionHeader('INVESTMENT CATEGORIES', Icons.category_outlined),
            const SizedBox(height: 16),
            _buildCategoryGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioCard() {
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
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total MF Valuation', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('₹12,45,000', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('+18.4%', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 1),
                      const FlSpot(1, 1.5),
                      const FlSpot(2, 1.3),
                      const FlSpot(3, 2),
                      const FlSpot(4, 1.8),
                      const FlSpot(5, 2.5),
                      const FlSpot(6, 3),
                    ],
                    isCurved: true,
                    color: const Color(0xFFEAB308),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFEAB308).withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: const Color(0xFF1E293B),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '₹${(spot.y * 4).toStringAsFixed(1)}L',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildSimpleStat('Invested', '₹8.5L'),
              const SizedBox(width: 40),
              _buildSimpleStat('Gain', '₹3.9L', color: const Color(0xFF10B981)),
              const Spacer(),
              const Text('LAST 12 MONTHS', style: TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, {Color color = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
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

  Widget _buildInvestBridgeCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildBridgeCard(
            context, 
            'EQUITY', 
            'MARKET', 
            const Color(0xFFEAB308), 
            Icons.trending_up,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EquityScreen())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildBridgeCard(
            context, 
            'TAX', 
            'SAVING', 
            const Color(0xFF10B981), 
            Icons.security,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxSavingScreen())),
          ),
        ),
      ],
    );
  }

  Widget _buildBridgeCard(BuildContext context, String title, String sub, Color color, IconData icon, VoidCallback onTap) {
    return GlassCard(
      padding: EdgeInsets.zero,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFundList() {
    return Column(
      children: [
        _buildFundCard('Quant Small Cap Fund', 'Equity • Small Cap', '48.2%', '+12.4%'),
        const SizedBox(height: 12),
        _buildFundCard('Parag Parikh Flexi Cap', 'Equity • Flexi Cap', '32.1%', '+8.2%'),
        const SizedBox(height: 12),
        _buildFundCard('ICICI Prudential Bluechip', 'Equity • Large Cap', '24.5%', '+5.1%'),
      ],
    );
  }

  Widget _buildFundCard(String name, String type, String returns, String change) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 4),
                Text(type, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(returns, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 4),
              Text(change, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Equity', 'icon': Icons.show_chart, 'color': Colors.blue},
      {'name': 'Debt', 'icon': Icons.account_balance, 'color': Colors.orange},
      {'name': 'Hybrid', 'icon': Icons.pie_chart, 'color': Colors.purple},
      {'name': 'ELSS', 'icon': Icons.verified_user_outlined, 'color': Colors.green},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final name = cat['name'] as String;
        
        return GlassCard(
          padding: EdgeInsets.zero,
          opacity: 0.08,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DetailedAnalysisScreen(
                title: name,
                content: 'Deep dive analysis for $name mutual funds. Our AI models suggest a strategic approach based on current market valuations and your risk profile.',
              )));
            },
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'] as IconData, color: (cat['color'] as Color).withOpacity(0.7), size: 24),
                const SizedBox(height: 12),
                Text(name, 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
