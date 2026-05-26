import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/1_voice_to_notes/data/models/lecture_model.dart';
import 'features/1_voice_to_notes/providers/audio_recording_provider.dart';
import 'features/1_voice_to_notes/providers/notes_generation_provider.dart';
import 'features/1_voice_to_notes/providers/lectures_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Hive
  await Hive.initFlutter();
  Hive.registerAdapter(LectureModelAdapter());

  runApp(const DraftItApp());
}

class DraftItApp extends StatelessWidget {
  const DraftItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth — top level, always alive
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Voice-to-notes providers
        ChangeNotifierProvider(create: (_) => AudioRecordingProvider()),
        ChangeNotifierProvider(create: (_) => NotesGenerationProvider()),
        ChangeNotifierProvider(create: (_) => LecturesProvider()),
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