import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  late TabController _tabController;
  List<dynamic> _articles = [];
  bool _isLoading = true;
  String _currentCategory = 'all';

  final List<String> _categories = ['all', 'finance', 'investments', 'banking'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    _fetchNews();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentCategory = _categories[_tabController.index];
      _isLoading = true;
    });
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      final data = await _api.getNewsFeed(category: _currentCategory);
      setState(() {
        _articles = data['articles'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch article')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: const Text('ET NEWS', 
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.w900, 
            letterSpacing: 2.0,
            color: Colors.white,
          )
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFFEAB308),
          labelColor: const Color(0xFFEAB308),
          unselectedLabelColor: Colors.white.withOpacity(0.5),
          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.0),
          tabs: _categories.map((cat) => Tab(text: cat.toUpperCase())).toList(),
        ),
      ),
      body: DynamicGradientBackground(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFEAB308)))
          : RefreshIndicator(
              onRefresh: _fetchNews,
              color: const Color(0xFFEAB308),
              child: ListView.builder(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 100,
                  left: 20,
                  right: 20,
                  bottom: 100,
                ),
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  if (index == 0) return _buildHeroCard(article);
                  return _buildNewsCard(article);
                },
              ),
            ),
      ),
    );
  }

  Widget _buildHeroCard(dynamic article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(28),
        opacity: 0.15,
        isGold: true,
        child: InkWell(
          onTap: () => _launchUrl(article['url']),
          borderRadius: BorderRadius.circular(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Image.network(
                  article['image_url'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.white.withOpacity(0.05),
                    child: const Icon(Icons.newspaper, color: Colors.white24, size: 48),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAB308).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(article['category'].toUpperCase(), 
                            style: const TextStyle(color: Color(0xFFEAB308), fontSize: 8, fontWeight: FontWeight.w900)
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(article['source'], 
                          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.bold)
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(article['title'], 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, height: 1.3)
                    ),
                    const SizedBox(height: 8),
                    Text(article['description'], 
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, height: 1.4)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(dynamic article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: BorderRadius.circular(20),
        opacity: 0.08,
        child: InkWell(
          onTap: () => _launchUrl(article['url']),
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article['image_url'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.white.withOpacity(0.05),
                    child: const Icon(Icons.newspaper, color: Colors.white24, size: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article['title'], 
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white, height: 1.2)
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(article['source'], 
                          style: TextStyle(color: Color(0xFFEAB308).withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: TextStyle(color: Colors.white.withOpacity(0.2))),
                        const SizedBox(width: 8),
                        Text(_formatTime(article['published_at']), 
                          style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 9)
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      final diff = DateTime.now().difference(date);
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return '';
    }
  }
}
