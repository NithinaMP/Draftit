// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:provider/provider.dart';
//
// import 'core/theme/app_theme.dart';
// import 'core/router/app_router.dart';
// import 'core/constants/app_constants.dart';
// import 'features/auth/providers/auth_provider.dart';
// import 'features/1_voice_to_notes/data/models/lecture_model.dart';
// import 'features/1_voice_to_notes/providers/audio_recording_provider.dart';
// import 'features/1_voice_to_notes/providers/notes_generation_provider.dart';
// import 'features/1_voice_to_notes/providers/lectures_provider.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // Load .env FIRST
//   await dotenv.load(fileName: '.env');
//
//   if (!AppConstants.isKeyValid) {
//     debugPrint(
//       '\n══════════════════════════════════════════\n'
//           '⚠️  Groq API key missing or invalid!\n'
//           '   Open .env and set:\n'
//           '   GROQ_API_KEY=gsk_your_actual_key_here\n'
//           '   Get a free key at: console.groq.com\n'
//           '══════════════════════════════════════════\n',
//     );
//   } else {
//     debugPrint('✅ Groq key loaded: ${AppConstants.groqApiKey.substring(0, 8)}...');
//   }
//
//   await Firebase.initializeApp();
//
//   await Hive.initFlutter();
//   Hive.registerAdapter(LectureModelAdapter());
//
//   runApp(const DraftItApp());
// }
//
// class DraftItApp extends StatelessWidget {
//   const DraftItApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => AudioRecordingProvider()),
//         ChangeNotifierProvider(create: (_) => NotesGenerationProvider()),
//         ChangeNotifierProvider(create: (_) => LecturesProvider()),
//       ],
//       child: MaterialApp(
//         title: 'DraftIt',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.dark,
//         onGenerateRoute: AppRouter.generateRoute,
//         home: const AuthGate(),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/1_voice_to_notes/data/models/lecture_model.dart';
import 'features/1_voice_to_notes/providers/audio_recording_provider.dart';
import 'features/1_voice_to_notes/providers/notes_generation_provider.dart';
import 'features/1_voice_to_notes/providers/lectures_provider.dart';
import 'features/2_study_buddy/data/models/exam_question_model.dart';
import 'features/2_study_buddy/data/models/syllabus_model.dart';
import 'features/2_study_buddy/providers/exam_predictor_provider.dart';
import 'features/2_study_buddy/providers/syllabus_provider.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

await dotenv.load(fileName: '.env');

if (!AppConstants.isKeyValid) {
debugPrint(
'\n══════════════════════════════════════════\n'
'⚠️  Groq API key missing or invalid!\n'
'   Open .env and set:\n'
'   GROQ_API_KEY=gsk_your_actual_key_here\n'
'══════════════════════════════════════════\n',
);
} else {
debugPrint('✅ Groq key loaded: ${AppConstants.groqApiKey.substring(0, 8)}...');
}

await Firebase.initializeApp();

await Hive.initFlutter();
// Phase 1
Hive.registerAdapter(LectureModelAdapter());
// Phase 2
Hive.registerAdapter(ExamQuestionAdapter());
Hive.registerAdapter(SyllabusUnitAdapter());

runApp(const DraftItApp());
}

class DraftItApp extends StatelessWidget {
const DraftItApp({super.key});

@override
Widget build(BuildContext context) {
return MultiProvider(
providers: [
// Auth
ChangeNotifierProvider(create: (_) => AuthProvider()),
// Phase 1
ChangeNotifierProvider(create: (_) => AudioRecordingProvider()),
ChangeNotifierProvider(create: (_) => NotesGenerationProvider()),
ChangeNotifierProvider(create: (_) => LecturesProvider()),
// Phase 2
ChangeNotifierProvider(create: (_) => ExamPredictorProvider()),
ChangeNotifierProvider(create: (_) => SyllabusProvider()),
],
child: MaterialApp(
title: 'DraftIt',
debugShowCheckedModeBanner: false,
theme: AppTheme.dark,
onGenerateRoute: AppRouter.generateRoute,
home: const AuthGate(),
),
);
}
}
