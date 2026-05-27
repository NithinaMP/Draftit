import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class HuggingFaceClient {
  static final HuggingFaceClient _instance = HuggingFaceClient._internal();
  factory HuggingFaceClient() => _instance;
  HuggingFaceClient._internal();

  Dio get _dio => Dio(BaseOptions(
    baseUrl: 'https://api-inference.huggingface.co',
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 300),
    headers: {
      'Authorization': 'Bearer ${AppConstants.huggingFaceApiKey}',
    },
  ));

  Future<String> transcribeAudio(Uint8List audioBytes) async {
    if (!AppConstants.isKeyValid) {
      throw Exception(
          'AUTH_ERROR: Open your .env file and set HF_API_KEY=hf_yourkey');
    }

    debugPrint('🎙 Sending ${audioBytes.length} bytes to Whisper...');

    try {
      final response = await _dio.post(
        '/models/${AppConstants.whisperModel}',
        data: audioBytes,
        options: Options(
          contentType: 'audio/aac',
          responseType: ResponseType.json,
          headers: {'X-Wait-For-Model': 'true'},
        ),
      );

      debugPrint('✅ Whisper response: ${response.data}');

      if (response.data is Map && response.data.containsKey('text')) {
        return response.data['text'] as String;
      }
      throw Exception('INVALID_RESPONSE: ${response.data}');
    } on DioException catch (e) {
      debugPrint('❌ Whisper DioError: [${e.response?.statusCode}] ${e.message}');
      debugPrint('   Response body: ${e.response?.data}');
      throw _toFriendly(e);
    }
  }

  Future<String> generateText({
    required String prompt,
    int maxNewTokens = 900,
    double temperature = 0.2,
  }) async {
    debugPrint('🤖 Sending prompt to Mistral...');

    try {
      final response = await _dio.post(
        '/models/${AppConstants.textModel}',
        data: {
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': maxNewTokens,
            'temperature': temperature,
            'return_full_text': false,
          },
        },
        options: Options(headers: {'X-Wait-For-Model': 'true'}),
      );

      debugPrint('✅ Mistral response received');

      if (response.data is List && (response.data as List).isNotEmpty) {
        return response.data[0]['generated_text'] as String;
      }
      throw Exception('INVALID_GENERATION_RESPONSE: ${response.data}');
    } on DioException catch (e) {
      debugPrint('❌ Mistral DioError: [${e.response?.statusCode}] ${e.message}');
      debugPrint('   Response body: ${e.response?.data}');
      throw _toFriendly(e);
    }
  }

  Exception _toFriendly(DioException e) {
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return Exception('AUTH_ERROR');
    }
    if (status == 503) {
      return Exception('MODEL_LOADING');
    }
    if (status == 429) {
      return Exception('RATE_LIMIT');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('TIMEOUT');
    }
    if (e.type == DioExceptionType.unknown) {
      return Exception('NETWORK_ERROR: ${e.message}');
    }
    return Exception('API_ERROR [$status]: ${e.response?.data}');
  }
}