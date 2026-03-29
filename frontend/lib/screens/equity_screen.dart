import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class EquityScreen extends StatelessWidget {
  const EquityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('EQUITY MARKET', 
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
            _buildIndicesRow(),
            const SizedBox(height: 32),
            _buildSectionHeader('YOUR PORTFOLIO', Icons.pie_chart_outline),
            const SizedBox(height: 16),
            _buildPortfolioCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('TOP GAINERS', Icons.trending_up),
            const SizedBox(height: 16),
            _buildStockList(),
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

  Widget _buildIndicesRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildIndexCard('NIFTY 50', '22,040.70', '+1.2%', const Color(0xFF10B981))),
            const SizedBox(width: 12),
            Expanded(child: _buildIndexCard('SENSEX', '72,410.38', '+0.9%', const Color(0xFF10B981))),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(24),
          opacity: 0.08,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('NIFTY 50 PERFORMANCE', style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              const SizedBox(height: 24),
              SizedBox(
                height: 140,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 11,
                    minY: 0,
                    maxY: 6,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(0, 3),
                          const FlSpot(2, 2.5),
                          const FlSpot(4, 5),
                          const FlSpot(5, 3.1),
                          const FlSpot(7, 4),
                          const FlSpot(8, 3.5),
                          const FlSpot(10, 5),
                          const FlSpot(11, 4.8),
                        ],
                        isCurved: true,
                        color: const Color(0xFF10B981),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF10B981).withOpacity(0.2),
                              const Color(0xFF10B981).withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: const Color(0xFF1E293B),
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '${22000 + (spot.y * 10).toInt()}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPeriodBadge('1D', true),
                  _buildPeriodBadge('1W', false),
                  _buildPeriodBadge('1M', false),
                  _buildPeriodBadge('1Y', false),
                  _buildPeriodBadge('ALL', false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodBadge(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white24, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildIndexCard(String name, String value, String change, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(change, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      opacity: 0.15,
      isGold: true,
      borderRadius: BorderRadius.circular(28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Portfolio Value', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('₹5,18,240', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
            ),
            child: const Text('+14.2%', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildStockList() {
    final stocks = [
      {'name': 'RELIANCE', 'price': '₹2,984.50', 'change': '+2.45%'},
      {'name': 'HDFC BANK', 'price': '₹1,442.10', 'change': '+1.82%'},
      {'name': 'INFY', 'price': '₹1,620.00', 'change': '+1.15%'},
      {'name': 'TCS', 'price': '₹4,120.35', 'change': '+0.75%'},
    ];

    return Column(
      children: stocks.map((stock) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          opacity: 0.08,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAB308).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(child: Icon(Icons.show_chart, color: Color(0xFFEAB308), size: 16)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                    const SizedBox(height: 2),
                    Text('NSE • INDIA', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(stock['price']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(stock['change']!, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10)),
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}
