// class AppConstants {
//   // HuggingFace
//   static const String huggingFaceApiKey = String.fromEnvironment(
//     'HF_API_KEY',
//     defaultValue: 'YOUR_HF_API_KEY_HERE',
//   );
//
//   static const String whisperModel = 'openai/whisper-large-v3';
//   static const String textModel = 'mistralai/Mistral-7B-Instruct-v0.3';
//
//   // Firestore
//   static const String usersCollection = 'users';
//   static const String lecturesCollection = 'lectures';
//
//   // Hive
//   static const String lecturesBoxName = 'lectures_box';
//   static const int lectureTypeId = 0;
// }
//


import 'package:flutter/foundation.dart';

class AppConstants {
  static const String _hfKey = String.fromEnvironment(
    'HF_API_KEY',
    defaultValue: 'NOT_SET',
  );

  static String get huggingFaceApiKey {
    if (_hfKey == 'NOT_SET' || _hfKey == 'YOUR_HF_API_KEY_HERE') {
      if (kDebugMode) {
        debugPrint(
          '\n'
              '══════════════════════════════════════════════\n'
              '⚠️  HuggingFace API key is NOT set!\n'
              '   Run the app with:\n'
              '   flutter run --dart-define=HF_API_KEY=hf_yourtoken\n'
              '   Get a free key at: huggingface.co/settings/tokens\n'
              '══════════════════════════════════════════════\n',
        );
      }
    }
    return _hfKey;
  }

  static const String whisperModel = 'openai/whisper-large-v3';
  static const String textModel    = 'mistralai/Mistral-7B-Instruct-v0.3';

  // Firestore
  static const String usersCollection   = 'users';
  static const String lecturesCollection = 'lectures';

  // Hive
  static const String lecturesBoxName = 'lectures_box';
  static const int    lectureTypeId   = 0;
}