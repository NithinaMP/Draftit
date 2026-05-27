// import 'dart:convert';
// import 'package:dio/dio.dart';
// import '../constants/app_constants.dart';
//
// class HuggingFaceClient {
//   static final HuggingFaceClient _instance = HuggingFaceClient._internal();
//   factory HuggingFaceClient() => _instance;
//   HuggingFaceClient._internal();
//
//   Dio get _dio => Dio(BaseOptions(
//     baseUrl: 'https://api-inference.huggingface.co',
//     connectTimeout: const Duration(seconds: 30),
//     receiveTimeout: const Duration(seconds: 180),
//     headers: {
//       'Authorization': 'Bearer ${AppConstants.huggingFaceApiKey}',
//     },
//   ));
//
//   /// Transcribe raw audio bytes with Whisper.
//   /// Retries once if model is loading (503).
//   Future<String> transcribeAudio(List<int> audioBytes) async {
//     return _withModelWarmup(() async {
//       final response = await _dio.post(
//         '/models/${AppConstants.whisperModel}',
//         data: audioBytes,
//         options: Options(
//           contentType: 'audio/aac',
//           responseType: ResponseType.json,
//           // Tell HF to wait for model to load instead of returning 503
//           headers: {'X-Wait-For-Model': 'true'},
//         ),
//       );
//       final data = response.data;
//       if (data is Map && data.containsKey('text')) {
//         return data['text'] as String;
//       }
//       throw Exception('Whisper response missing "text" field. Got: $data');
//     });
//   }
//
//   /// Generate text from a prompt using Mistral.
//   /// Retries once if model is loading (503).
//   Future<String> generateText({
//     required String prompt,
//     int maxNewTokens = 1024,
//     double temperature = 0.2,
//   }) async {
//     return _withModelWarmup(() async {
//       final response = await _dio.post(
//         '/models/${AppConstants.textModel}',
//         data: {
//           'inputs': prompt,
//           'parameters': {
//             'max_new_tokens': maxNewTokens,
//             'temperature': temperature,
//             'return_full_text': false,
//           },
//         },
//         options: Options(
//           headers: {'X-Wait-For-Model': 'true'},
//         ),
//       );
//
//       if (response.data is List && (response.data as List).isNotEmpty) {
//         return response.data[0]['generated_text'] as String;
//       }
//       throw Exception('Unexpected response format from Mistral: ${response.data}');
//     });
//   }
//
//   /// Wraps a request: if we get 503 "model loading", wait and retry once.
//   Future<T> _withModelWarmup<T>(Future<T> Function() request) async {
//     try {
//       return await request();
//     } on DioException catch (e) {
//       final status = e.response?.statusCode;
//       final body = e.response?.data;
//
//       // 503 = model is cold/loading — wait 20s and retry once
//       if (status == 503) {
//         final isLoading = body.toString().toLowerCase().contains('loading');
//         if (isLoading) {
//           await Future.delayed(const Duration(seconds: 20));
//           return await request();
//         }
//       }
//
//       // Re-throw with a human-readable message
//       throw _friendlyException(e);
//     }
//   }
//
//   Exception _friendlyException(DioException e) {
//     final status = e.response?.statusCode;
//     final body = e.response?.data?.toString() ?? '';
//
//     if (status == 401 || status == 403) {
//       return Exception(
//         'AUTH_ERROR: Your HuggingFace API key is invalid or not set. '
//             'Make sure you run: flutter run --dart-define=HF_API_KEY=hf_yourtoken',
//       );
//     }
//     if (status == 503) {
//       return Exception(
//         'MODEL_LOADING: The AI model is still warming up. Wait 30 seconds and try again.',
//       );
//     }
//     if (status == 429) {
//       return Exception(
//         'RATE_LIMIT: Too many requests. Wait a minute and try again.',
//       );
//     }
//     if (status == 400) {
//       return Exception('BAD_REQUEST: $body');
//     }
//     if (e.type == DioExceptionType.connectionTimeout ||
//         e.type == DioExceptionType.receiveTimeout) {
//       return Exception(
//         'TIMEOUT: The request took too long. Check your internet and try again.',
//       );
//     }
//     return Exception('API_ERROR [$status]: $body');
//   }
// }

// import 'dart:typed_data';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import '../constants/app_constants.dart';
//
// class HuggingFaceClient {
//   static final HuggingFaceClient _instance = HuggingFaceClient._internal();
//   factory HuggingFaceClient() => _instance;
//   HuggingFaceClient._internal();
//
//   Dio get _dio => Dio(BaseOptions(
//     baseUrl: 'https://api-inference.huggingface.co',
//     connectTimeout: const Duration(seconds: 60),
//     receiveTimeout: const Duration(seconds: 300), // 5 minutes for cold start
//     headers: {
//       'Authorization': 'Bearer ${AppConstants.huggingFaceApiKey}',
//     },
//   ));
//
//   Future<String> transcribeAudio(Uint8List audioBytes) async {
//     if (AppConstants.huggingFaceApiKey == 'NOT_SET' ||
//         AppConstants.huggingFaceApiKey.length < 20) {
//       throw Exception('AUTH_ERROR: HuggingFace API key is not set properly.');
//     }
//
//     try {
//       final response = await _dio.post(
//         '/models/${AppConstants.whisperModel}',
//         data: audioBytes,
//         options: Options(
//           contentType: 'audio/aac',
//           responseType: ResponseType.json,
//           headers: {'X-Wait-For-Model': 'true'},
//         ),
//       );
//
//       if (response.data is Map && response.data.containsKey('text')) {
//         return response.data['text'] as String;
//       }
//       throw Exception('INVALID_RESPONSE');
//     } on DioException catch (e) {
//       debugPrint('❌ Whisper Error: ${e.response?.statusCode} - ${e.message}');
//       throw _friendlyException(e);
//     }
//   }
//
//   Future<String> generateText({
//     required String prompt,
//     int maxNewTokens = 1024,
//     double temperature = 0.25,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/models/${AppConstants.textModel}',
//         data: {
//           'inputs': prompt,
//           'parameters': {
//             'max_new_tokens': maxNewTokens,
//             'temperature': temperature,
//             'return_full_text': false,
//           },
//         },
//         options: Options(headers: {'X-Wait-For-Model': 'true'}),
//       );
//
//       if (response.data is List && response.data.isNotEmpty) {
//         return response.data[0]['generated_text'] as String;
//       }
//       throw Exception('INVALID_GENERATION_RESPONSE');
//     } on DioException catch (e) {
//       debugPrint('❌ Mistral Error: ${e.response?.statusCode}');
//       throw _friendlyException(e);
//     }
//   }
//
//   Exception _friendlyException(DioException e) {
//     final status = e.response?.statusCode;
//     if (status == 401 || status == 403) {
//       return Exception('AUTH_ERROR');
//     }
//     if (status == 503) {
//       return Exception('MODEL_LOADING');
//     }
//     if (status == 429) {
//       return Exception('RATE_LIMIT');
//     }
//     if (e.type == DioExceptionType.connectionTimeout ||
//         e.type == DioExceptionType.receiveTimeout) {
//       return Exception('TIMEOUT');
//     }
//     return Exception('API_ERROR: ${e.message}');
//   }
// }



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
    connectTimeout: const Duration(seconds: 45),
    receiveTimeout: const Duration(seconds: 300),
    headers: {
      'Authorization': 'Bearer ${AppConstants.huggingFaceApiKey}',
    },
  ));

  Future<String> transcribeAudio(Uint8List audioBytes) async {
    if (!AppConstants.isKeyValid) {
      throw Exception('AUTH_ERROR: HuggingFace API key is not set properly.');
    }

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

      if (response.data is Map && response.data.containsKey('text')) {
        return response.data['text'] as String;
      }
      throw Exception('INVALID_RESPONSE');
    } on DioException catch (e) {
      debugPrint('❌ Whisper Error: ${e.message}');
      throw _friendlyException(e);
    }
  }

  Future<String> generateText({
    required String prompt,
    int maxNewTokens = 1024,
    double temperature = 0.25,
  }) async {
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

      if (response.data is List && response.data.isNotEmpty) {
        return response.data[0]['generated_text'] as String;
      }
      throw Exception('INVALID_GENERATION_RESPONSE');
    } on DioException catch (e) {
      debugPrint('❌ Mistral Error: ${e.message}');
      throw _friendlyException(e);
    }
  }

  Exception _friendlyException(DioException e) {
    if (e.type == DioExceptionType.unknown && e.message?.contains('Failed host lookup') == true) {
      return Exception('NETWORK_ERROR: Cannot reach Hugging Face servers. Check your internet/DNS.');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('TIMEOUT: Request timed out.');
    }
    return Exception('API_ERROR: ${e.message}');
  }
}