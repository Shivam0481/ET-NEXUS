/// Data models for the ET NEXUS app.
library;

class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String content;
  final String? intent;
  final List<Map<String, dynamic>> entities;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.intent,
    this.entities = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      role: json['role'] ?? 'assistant',
      content: json['content'] ?? '',
      intent: json['intent'],
      entities: List<Map<String, dynamic>>.from(json['entities'] ?? []),
    );
  }
}

class Recommendation {
  final String title;
  final String type; // product | content | event
  final String? entityId;
  final String explanation;
  final double confidenceScore;
  final List<String> relevanceFactors;

  Recommendation({
    required this.title,
    required this.type,
    this.entityId,
    required this.explanation,
    required this.confidenceScore,
    this.relevanceFactors = const [],
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      title: json['title'] ?? '',
      type: json['type'] ?? 'product',
      entityId: json['entity_id'],
      explanation: json['explanation'] ?? '',
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
      relevanceFactors: List<String>.from(json['relevance_factors'] ?? []),
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final bool etPrimeMember;
  final String? riskAppetite;
  final List<String> financialGoals;
  final String? investmentHorizon;
  final String? experienceLevel;
  final String profilingStage;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.etPrimeMember = false,
    this.riskAppetite,
    this.financialGoals = const [],
    this.investmentHorizon,
    this.experienceLevel,
    this.profilingStage = 'intro',
  });
}
