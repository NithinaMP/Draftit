import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/shell/main_shell.dart';
import 'features/1_voice_to_notes/data/models/lecture_model.dart';
import 'features/1_voice_to_notes/providers/audio_recording_provider.dart';
import 'features/1_voice_to_notes/providers/notes_generation_provider.dart';
import 'features/1_voice_to_notes/providers/lectures_provider.dart';
import 'features/2_study_buddy/data/models/exam_question_model.dart';
import 'features/2_study_buddy/data/models/syllabus_model.dart';
import 'features/2_study_buddy/providers/exam_predictor_provider.dart';
import 'features/2_study_buddy/providers/syllabus_provider.dart';
import 'features/3_career_builder/data/models/master_profile_model.dart';
import 'features/3_career_builder/data/models/job_application_model.dart';
import 'features/3_career_builder/providers/master_profile_provider.dart';
import 'features/3_career_builder/providers/job_application_provider.dart';
import 'features/splash/splash_screen.dart';

import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  if (!AppConstants.isKeyValid) {
  }
  await Firebase.initializeApp();

  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: true,
    );
    return true;
  };

  await Hive.initFlutter();
  Hive.registerAdapter(LectureModelAdapter());
  Hive.registerAdapter(ExamQuestionAdapter());
  Hive.registerAdapter(SyllabusUnitAdapter());
  Hive.registerAdapter(EducationEntryAdapter());
  Hive.registerAdapter(ExperienceEntryAdapter());
  Hive.registerAdapter(MasterProfileAdapter());
  Hive.registerAdapter(CertificationEntryAdapter());
  Hive.registerAdapter(ProjectEntryAdapter());
  Hive.registerAdapter(JobApplicationAdapter());
  runApp(const DraftItApp());
}

class DraftItApp extends StatelessWidget {
  const DraftItApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider wraps everything ABOVE MaterialApp
    // so ALL routes — including ones pushed via Navigator — inherit the providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AudioRecordingProvider()),
        ChangeNotifierProvider(create: (_) => NotesGenerationProvider()),
        ChangeNotifierProvider(create: (_) => LecturesProvider()),
        ChangeNotifierProvider(create: (_) => ExamPredictorProvider()),
        ChangeNotifierProvider(create: (_) => SyllabusProvider()),
        ChangeNotifierProvider(create: (_) => MasterProfileProvider()),
        ChangeNotifierProvider(create: (_) => JobApplicationProvider()),
      ],
      // Consumer<ThemeProvider> is a child of MultiProvider,
      // so context here already has ThemeProvider available
      child: Consumer<ThemeProvider>(
        builder: (ctx, themeProvider, _) => MaterialApp(
          title: 'DraftIt',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          // 3. Tell Flutter to watch the mobile operating system's theme
          // themeMode: ThemeMode.system,

          themeMode: themeProvider.mode,

          onGenerateRoute: AppRouter.generateRoute,

          // All routes pushed from here inherit the MultiProvider above
          // home: const AppBootstrap(),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

/// Watches auth state and resets providers when user changes
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  String? _lastUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthProvider>();
    final uid = auth.user?.uid;

    if (uid != null && uid != _lastUid) {
      _lastUid = uid;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<LecturesProvider>().startListening();
        context.read<MasterProfileProvider>().clearForNewUser();
        context.read<JobApplicationProvider>().clearForNewUser();
        context.read<ExamPredictorProvider>().clearForNewUser();
        context.read<SyllabusProvider>().clearForNewUser();
      });
    }

    if (uid == null) _lastUid = null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (auth.user == null) return const LoginScreen();
    return const MainShell();
  }
}