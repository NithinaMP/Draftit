import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get groqApiKey {
    final key = dotenv.env['GROQ_API_KEY'] ?? '';
    return key;
  }

  static bool get isKeyValid {
    final key = groqApiKey;
    return key.isNotEmpty &&
        key != 'gsk_paste_your_actual_key_here' &&
        key.startsWith('gsk_') &&
        key.length > 20;
  }

  // Groq model IDs
  static const String whisperModel = 'whisper-large-v3';
  static const String textModel    = 'llama-3.1-8b-instant';

  // Firestore
  static const String usersCollection    = 'users';
  static const String lecturesCollection = 'lectures';

  // Hive
  static const String lecturesBoxName = 'lectures_box';
  static const int    lectureTypeId   = 0;
}