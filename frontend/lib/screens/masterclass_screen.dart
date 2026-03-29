import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class MasterclassScreen extends StatefulWidget {
  const MasterclassScreen({super.key});

  @override
  State<MasterclassScreen> createState() => _MasterclassScreenState();
}

class _MasterclassScreenState extends State<MasterclassScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'v6OmsuS1Q2M', // Educational Finance Video: "How to Invest for Beginners"
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MASTERCLASSES', 
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
            _buildFeaturedVideoCard(),
            const SizedBox(height: 32),
            _buildSectionHeader('UPCOMING LIVE SESSIONS', Icons.live_tv),
            const SizedBox(height: 16),
            _buildSessionCard('Advanced Options Trading', 'with Sunita Sharma', 'Mar 30, 6:00 PM'),
            const SizedBox(height: 12),
            _buildSessionCard('Retirement Planning 101', 'with Rajesh Khanna', 'Apr 02, 7:30 PM'),
            const SizedBox(height: 32),
            _buildSectionHeader('POPULAR COURSES', Icons.play_circle_fill),
            const SizedBox(height: 16),
            _buildCourseGrid(),
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

  Widget _buildFeaturedVideoCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      opacity: 0.15,
      borderRadius: BorderRadius.circular(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The Art of Portfolio Rebalancing', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('Learn how to protect your gains during market volatility.', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(String title, String host, String time) {
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
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 4),
                Text(host, style: TextStyle(color: const Color(0xFFEAB308).withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time.split(',')[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              const SizedBox(height: 4),
              Text(time.split(',')[1], style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 0.8,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildCourseItem('Stocks for Beginners', '12 Lessons'),
        _buildCourseItem('Advanced Crypto', '8 Lessons'),
      ],
    );
  }

  Widget _buildCourseItem(String title, String lessons) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      opacity: 0.08,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school_outlined, color: Color(0xFFEAB308), size: 32),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
          const SizedBox(height: 8),
          Text(lessons, style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
