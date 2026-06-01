import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/1_voice_to_notes/presentation/dashboard_screen.dart';
import '../../features/1_voice_to_notes/presentation/recorder_screen.dart';
import '../../features/1_voice_to_notes/presentation/notes_viewer_screen.dart';
import '../../features/2_study_buddy/presentation/screens/study_buddy_screen.dart';
import '../../features/2_study_buddy/presentation/screens/syllabus_tracker_screen.dart';
import '../../features/3_career_builder/presentation/screens/career_builder_screen.dart';
import '../../features/3_career_builder/presentation/screens/master_profile_screen.dart';
import '../../features/3_career_builder/presentation/screens/jd_input_screen.dart';
import '../presentation/main_shell.dart';

class AppRouter {
  static const String login          = '/login';
  static const String dashboard      = '/dashboard';
  static const String recorder       = '/recorder';
  static const String notesViewer    = '/notes';
  static const String studyBuddy     = '/study-buddy';
  static const String syllabus       = '/syllabus';
  static const String careerBuilder  = '/career';
  static const String masterProfile  = '/career/profile';
  static const String jdInput        = '/career/jd';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _route(const LoginScreen());
      case dashboard:
        // return _route(const DashboardScreen());
        return _route(const MainShell());

      case recorder:
        return _route(const RecorderScreen());
      case notesViewer:
        return _route(NotesViewerScreen(lectureId: settings.arguments as String));
      case studyBuddy:
        return _route(const StudyBuddyScreen());
      case syllabus:
        return _route(const SyllabusTrackerScreen());
      case careerBuilder:
        return _route(const CareerBuilderScreen());
      case masterProfile:
        return _route(const MasterProfileScreen());
      case jdInput:
        return _route(const JdInputScreen());
      default:
        return _route(const Scaffold(
          body: Center(child: Text('Route not found')),
        ));
    }
  }

  static MaterialPageRoute _route(Widget page) =>
      MaterialPageRoute(builder: (_) => page);
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.isLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (auth.user == null) return const LoginScreen();
        return const DashboardScreen();
      },
    );
  }
}