import 'package:dio/dio.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  late final Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // ── Chat ──
  Future<Map<String, dynamic>> sendMessage({
    String? conversationId,
    required String message,
    Map<String, dynamic>? context,
  }) async {
    final response = await _dio.post('/chat/message', data: {
      'conversation_id': conversationId,
      'message': message,
      'context': context,
    });
    return response.data;
  }

  Future<List<dynamic>> getConversations() async {
    final response = await _dio.get('/chat/conversations');
    return response.data['conversations'] ?? [];
  }

  // ── User ──
  Future<Map<String, dynamic>> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final response = await _dio.post('/user/register', data: {
      'email': email,
      'full_name': fullName,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/user/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/user/profile');
    return response.data;
  }

  Future<Map<String, dynamic>> getInsights() async {
    final response = await _dio.get('/user/insights');
    return response.data;
  }

  // ── Events ──
  Future<void> trackEvent({
    required String eventType,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? eventData,
  }) async {
    await _dio.post('/event/track', data: {
      'event_type': eventType,
      'entity_type': entityType,
      'entity_id': entityId,
      'event_data': eventData ?? {},
    });
  }

  // ── Recommendations ──
  Future<Map<String, dynamic>> getRecommendationFeed({int page = 1}) async {
    final response = await _dio.get('/recommend/feed', queryParameters: {'page': page});
    return response.data;
  }

  Future<Map<String, dynamic>> getProductCatalog({
    String? category,
    String? risk,
  }) async {
    final response = await _dio.get('/recommend/products/catalog', queryParameters: {
      if (category != null) 'category': category,
      if (risk != null) 'risk': risk,
    });
    return response.data;
  }

  // ── News ──
  Future<Map<String, dynamic>> getNewsFeed({String? category, int pageSize = 20}) async {
    final response = await _dio.get('/news/feed', queryParameters: {
      if (category != null && category != 'all') 'category': category,
      'page_size': pageSize,
    });
    return response.data;
  }
}
