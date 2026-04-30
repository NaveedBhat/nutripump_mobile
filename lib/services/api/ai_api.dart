import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/product.dart';

class AiChatMessage {
  final String role;
  final String text;
  final List<Product>? products;
  final DateTime timestamp;

  AiChatMessage({
    required this.role,
    required this.text,
    this.products,
    required this.timestamp,
  });
}

class AiApi {
  late final Dio _dio;

  AiApi() {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://www.nutripump.store';
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  Future<AiChatMessage> sendMessage(String query) async {
    try {
      final response = await _dio.post('/api/ai/chat', data: {'query': query});

      if (response.statusCode == 200) {
        final data = response.data;
        
        final String messageText = data['message'] ?? 'Here are some recommendations for you!';
        final List<dynamic> productsJson = data['products'] ?? [];
        
        final List<Product> products = productsJson
            .map((p) => Product.fromMap(p as Map<String, dynamic>))
            .toList();

        return AiChatMessage(
          role: 'assistant',
          text: messageText,
          products: products,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('Failed to connect to AI assistant (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Could not reach the AI Assistant: $e');
    }
  }
}
