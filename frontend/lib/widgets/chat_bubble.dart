import 'package:flutter/material.dart';
import '../models/models.dart';
import 'glass_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = (message.role == 'user');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) _buildAvatar('🤖'),
              const SizedBox(width: 8),
              Flexible(
                child: isUser ? _buildUserBubble() : _buildAssistantBubble(),
              ),
              const SizedBox(width: 8),
              if (isUser) _buildAvatar('👤'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String emoji) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildUserBubble() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Text(
        message.content,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildAssistantBubble() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      opacity: 0.1,
      isGold: message.intent != 'general_chat' && message.intent != null,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (message.intent != null && message.intent!.isNotEmpty && message.intent != 'general_chat') ...[
            const SizedBox(height: 12),
            _buildIntentChip(),
          ],
          if (message.entities.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildEntityChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildIntentChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAB308).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAB308).withOpacity(0.3)),
      ),
      child: Text(
        message.intent!.replaceAll('_', ' ').toUpperCase(),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: Color(0xFFEAB308),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildEntityChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: message.entities.map((e) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            "${e['type']}: ${e['value']}",
            style: const TextStyle(fontSize: 10, color: Colors.white54),
          ),
        );
      }).toList(),
    );
  }
}
