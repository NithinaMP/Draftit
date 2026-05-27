import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // Reads HF_API_KEY from .env file at runtime
  static String get huggingFaceApiKey {
    final key = dotenv.env['HF_API_KEY'] ?? '';
    return key;
  }

  static bool get isKeyValid {
    final key = huggingFaceApiKey;
    return key.isNotEmpty &&
        key != 'hf_paste_your_actual_key_here' &&
        key.startsWith('hf_') &&
        key.length > 20;
  }

  static const String whisperModel = 'openai/whisper-large-v3';
  static const String textModel = 'mistralai/Mistral-7B-Instruct-v0.3';

  // Firestore
  static const String usersCollection = 'users';
  static const String lecturesCollection = 'lectures';

  // Hive
  static const String lecturesBoxName = 'lectures_box';
  static const int lectureTypeId = 0;
}