import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/rec_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/dynamic_gradient_background.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _api = ApiService();

  String? _conversationId;
  String _profilingStage = 'intro';
  final List<ChatMessage> _messages = [];
  final List<Recommendation> _recommendations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendGreeting();
  }

  Future<void> _sendGreeting() async {
    // Hidden greeting to wake up the assistant
    await _sendMessage('Hello', hidden: true);
  }

  Future<void> _sendMessage(String text, {bool hidden = false}) async {
    if (text.trim().isEmpty) return;

    if (!hidden) {
      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          role: 'user',
          content: text,
        ));
        _isLoading = true;
      });
      _scrollToBottom();
    }
    _controller.clear();

    try {
      final response = await _api.sendMessage(
        conversationId: _conversationId,
        message: text,
      );

      _conversationId = response['conversation_id'];
      _profilingStage = response['profiling_stage'] ?? _profilingStage;

      final msg = response['message'];
      setState(() {
        _messages.add(ChatMessage(
          id: msg['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          role: msg['role'] ?? 'assistant',
          content: msg['content'] ?? '',
          intent: msg['intent'],
          entities: List<Map<String, dynamic>>.from(msg['entities'] ?? []),
        ));

        // Parse recommendations
        final recs = response['recommendations'] as List? ?? [];
        if (recs.isNotEmpty) {
          _recommendations.clear();
          for (var r in recs) {
            _recommendations.add(Recommendation.fromJson(r));
          }
        }

        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!hidden) {
        setState(() {
          _messages.add(ChatMessage(
            id: 'error',
            role: 'assistant',
            content: 'I\'m having trouble connecting. Please try again.',
          ));
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEAB308).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.2)),
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFFEAB308), size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ET NEXUS', 
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1.5,
                    color: Colors.white,
                  )
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text('AI ADVISOR • ACTIVE', 
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5))
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          _buildProfilingBadge(),
          const SizedBox(width: 16),
        ],
      ),
      body: DynamicGradientBackground(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 64),
            
            if (_recommendations.isNotEmpty) 
              _buildRecommendationStrip(),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildThinkingIndicator();
                  }
                  return ChatBubble(message: _messages[index]);
                },
              ),
            ),

            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildThinkingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFEAB308)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('ET NEXUS is thinking...', 
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3), fontStyle: FontStyle.italic)
          ),
        ],
      ),
    );
  }

  Widget _buildProfilingBadge() {
    final stageColors = {
      'intro': const Color(0xFF64748B),
      'goals': const Color(0xFF06B6D4),
      'risk': const Color(0xFFF59E0B),
      'portfolio': const Color(0xFF8B5CF6),
      'complete': const Color(0xFF10B981),
    };
    final color = stageColors[_profilingStage] ?? Colors.white;

    return Center(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        opacity: 0.1,
        borderRadius: BorderRadius.circular(100),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              _profilingStage.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationStrip() {
    return Container(
      height: 190,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _recommendations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: RecCard(recommendation: _recommendations[index]),
          );
        },
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(context).padding.bottom + 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        borderRadius: BorderRadius.circular(100),
        opacity: 0.1,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Ask about investments, ET Prime or masterclasses...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (val) => _sendMessage(val),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFEAB308),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => _sendMessage(_controller.text),
                icon: const Icon(Icons.arrow_upward, color: Color(0xFF0F172A), size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) => _dot(i)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(int index) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) => Opacity(
        opacity: 0.3 + (0.7 * value),
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white54,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}
