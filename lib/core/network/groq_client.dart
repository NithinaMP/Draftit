import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class GroqClient {
  static final GroqClient _instance = GroqClient._internal();
  factory GroqClient() => _instance;
  GroqClient._internal();

  // Groq REST API base
  static const _baseUrl = 'https://api.groq.com/openai/v1';

  Dio get _dio => Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 120),
    headers: {
      'Authorization': 'Bearer ${AppConstants.groqApiKey}',
    },
  ));

  /// Transcribe audio using Groq Whisper
  /// Groq expects multipart/form-data for audio
  Future<String> transcribeAudio(Uint8List audioBytes, String filename) async {
    if (!AppConstants.isKeyValid) {
      throw Exception(
          'AUTH_ERROR: Open .env and set API_KEY=yourkey');
    }


    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          audioBytes,
          filename: filename.replaceAll('.aac', '.m4a'),
          contentType: DioMediaType('audio', 'mp4'),
        ),
        'model': AppConstants.whisperModel,
        'response_format': 'json',
        'language': 'en',
      });

      final response = await _dio.post(
        '/audio/transcriptions',
        data: formData,
      );


      if (response.data is Map && response.data.containsKey('text')) {
        return response.data['text'] as String;
      }
      throw Exception('INVALID_RESPONSE: ${response.data}');
    } on DioException catch (e) {
      debugPrint('   Body: ${e.response?.data}');
      throw _toFriendly(e);
    }
  }

  /// Generate structured notes using Groq Llama 3
  Future<String> generateText({
    required String systemPrompt,
    required String userMessage,
    int maxTokens = 1024,
    double temperature = 0.2,
  }) async {

    try {
      final response = await _dio.post(
        '/chat/completions',
        data: {
          'model': AppConstants.textModel,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user',   'content': userMessage},
          ],
          'max_tokens': maxTokens,
          'temperature': temperature,
        },
      );


      final choices = response.data['choices'] as List;
      if (choices.isNotEmpty) {
        return choices[0]['message']['content'] as String;
      }
      throw Exception('INVALID_GENERATION_RESPONSE: ${response.data}');
    } on DioException catch (e) {
      throw _toFriendly(e);
    }
  }

  Exception _toFriendly(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) return Exception('AUTH_ERROR');
    if (status == 429)                  return Exception('RATE_LIMIT');
    if (status == 503 || status == 502) return Exception('SERVICE_DOWN');
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout)    return Exception('TIMEOUT');
    if (e.type == DioExceptionType.unknown)           return Exception('NETWORK_ERROR: ${e.message}');
    return Exception('API_ERROR [$status]: ${e.response?.data}');
  }
}