class AppConstants {
  // HuggingFace
  static const String huggingFaceApiKey = String.fromEnvironment(
    'HF_API_KEY',
    defaultValue: 'YOUR_HF_API_KEY_HERE',
  );

  static const String whisperModel = 'openai/whisper-large-v3';
  static const String textModel = 'mistralai/Mistral-7B-Instruct-v0.3';

  // Firestore
  static const String usersCollection = 'users';
  static const String lecturesCollection = 'lectures';

  // Hive
  static const String lecturesBoxName = 'lectures_box';
  static const int lectureTypeId = 0;
}