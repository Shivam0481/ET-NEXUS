import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';
import 'detailed_analysis_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _insights;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  Future<void> _fetchInsights() async {
    try {
      final data = await _api.getInsights();
      setState(() {
        _insights = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('STRATEGIC PROFILE', 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 2.0,
            color: Colors.white,
          )
        ),
      ),
      body: DynamicGradientBackground(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEAB308), strokeWidth: 2))
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 80,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 40),
                  _buildSectionHeader('YOUR STRATEGIC INSIGHTS', Icons.insights_rounded),
                  const SizedBox(height: 16),
                  _buildInsightGrid(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('FINANCIAL GOALS', Icons.flag_rounded),
                  const SizedBox(height: 16),
                  _buildGoalsRoadmap(),
                  const SizedBox(height: 32),
                  _buildCompletionStatus(),
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
        Icon(icon, size: 14, color: const Color(0xFFEAB308)),
        const SizedBox(width: 8),
        Text(title, 
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.4), letterSpacing: 1.5)
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.5), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF1E293B),
              child: Icon(Icons.person_rounded, size: 40, color: const Color(0xFFEAB308).withOpacity(0.9)),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEAB308).withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.2)),
            ),
            child: const Text('ET AI ANALYSIS', 
              style: TextStyle(color: Color(0xFFEAB308), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)
            ),
          ),
          const SizedBox(height: 8),
          const Text('Sophisticated Investor', 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsRoadmap() {
    final goals = [
      {'title': 'RETIREMENT FUND', 'progress': 0.65, 'amount': '₹1.2 Cr', 'target': '2045'},
      {'title': 'NEW SMART HOME', 'progress': 0.40, 'amount': '₹85 L', 'target': '2028'},
      {'title': 'WORLD TOUR', 'progress': 0.15, 'amount': '₹15 L', 'target': '2026'},
    ];

    return Column(
      children: goals.map((goal) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          opacity: 0.1,
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(goal['title'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                  Text(goal['target'] as String, style: TextStyle(color: const Color(0xFFEAB308).withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: goal['progress'] as double,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  color: const Color(0xFFEAB308),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${((goal['progress'] as double) * 100).toInt()}% ACHIEVED', style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                  Text('TARGET: ${goal['amount']}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildInsightGrid() {
    final risk = _insights?['risk_appetite']?.toString() ?? 'Moderate-Aggressive';
    
    // Handle list type for goals
    final goalsData = _insights?['financial_goals'];
    String goals = 'Retirement, Home, Travel';
    if (goalsData is List && goalsData.isNotEmpty) {
      goals = goalsData.join(', ');
    } else if (goalsData is String) {
      goals = goalsData;
    }

    final horizon = _insights?['investment_horizon']?.toString() ?? '15-20 Years';
    final level = _insights?['experience_level']?.toString() ?? 'Intermediate';

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildInsightCard(
              context, 'Risk Appetite', risk, Icons.auto_graph, const Color(0xFFEAB308),
              'Your risk appetite is $risk. You\'re comfortable with market fluctuations and prefer growth-oriented investments with moderate downside protection.',
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildInsightCard(
              context, 'Goals', goals, Icons.flag_rounded, const Color(0xFF06B6D4),
              'Your financial goals: $goals. Our AI has mapped a personalized roadmap to achieve each milestone within your target timeline.',
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildInsightCard(
              context, 'Horizon', horizon, Icons.timer_outlined, const Color(0xFF8B5CF6),
              'Your investment horizon is $horizon. This long-term outlook allows for aggressive equity allocation with compounding benefits.',
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildInsightCard(
              context, 'Exp. Level', level, Icons.school_outlined, const Color(0xFF10B981),
              'Your experience level is $level. You understand SIPs, mutual funds, and basic portfolio diversification with 2-3 years of active investing.',
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String value, IconData icon, Color accentColor, String detailContent) {
    return GlassCard(
      padding: EdgeInsets.zero,
      opacity: 0.1,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => DetailedAnalysisScreen(
            title: title,
            content: detailContent,
          )));
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(height: 16),
              Text(title.toString().toUpperCase(), 
                style: TextStyle(fontSize: 8, color: Colors.white.withOpacity(0.3), fontWeight: FontWeight.w900, letterSpacing: 1.0)
              ),
              const SizedBox(height: 6),
              Text(value.toString().toUpperCase(), 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5)
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionStatus() {
    double progress = 0.25; 
    if (_insights != null) {
      if (_insights!['risk_appetite'] != null) progress += 0.2;
      if (_insights!['financial_goals'] != null && _insights!['financial_goals'] is List && (_insights!['financial_goals'] as List).isNotEmpty) progress += 0.2;
      if (_insights!['investment_horizon'] != null) progress += 0.15;
      if (_insights!['experience_level'] != null) progress += 0.2;
    }
    progress = progress > 1.0 ? 1.0 : progress;

    return GlassCard(
      padding: const EdgeInsets.all(24),
      opacity: 0.08,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('STRATEGY MATURITY', 
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white.withOpacity(0.4), letterSpacing: 1.0)
              ),
              Text('${(progress * 100).toInt()}%', 
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFEAB308))
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFEAB308).withOpacity(0.3), blurRadius: 10, spreadRadius: -2)
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Your strategic profile is curated from our interactions. As we discuss more, your financial AI will further refine your investment roadmap.',
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, height: 1.6)
          ),
        ],
      ),
    );
  }
}
