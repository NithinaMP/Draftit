import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class HuggingFaceClient {
  static final HuggingFaceClient _instance = HuggingFaceClient._internal();
  factory HuggingFaceClient() => _instance;
  HuggingFaceClient._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api-inference.huggingface.co',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 120),
    headers: {
      'Authorization': 'Bearer ${AppConstants.huggingFaceApiKey}',
    },
  ));

  /// Transcribe raw audio bytes with Whisper
  Future<String> transcribeAudio(List<int> audioBytes) async {
    final response = await _dio.post(
      '/models/${AppConstants.whisperModel}',
      data: audioBytes,
      options: Options(
        contentType: 'audio/aac',
        responseType: ResponseType.json,
      ),
    );
    return response.data['text'] as String;
  }

  /// Generate text from a prompt using Mistral
  Future<String> generateText({
    required String prompt,
    int maxNewTokens = 1024,
    double temperature = 0.2,
  }) async {
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
    );


    if (response.data is List) {
      return response.data[0]['generated_text'] as String;
    }
    throw Exception('Unexpected response format from HuggingFace');
  }

}