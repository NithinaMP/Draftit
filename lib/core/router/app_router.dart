import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/shell/main_shell.dart';
import '../../features/1_voice_to_notes/presentation/recorder_screen.dart';
import '../../features/1_voice_to_notes/presentation/notes_viewer_screen.dart';
import '../../features/2_study_buddy/presentation/screens/syllabus_tracker_screen.dart';
import '../../features/3_career_builder/presentation/screens/master_profile_screen.dart';
import '../../features/3_career_builder/presentation/screens/jd_input_screen.dart';
import '../../features/3_career_builder/presentation/screens/optimization_view_screen.dart';

class AppRouter {
  static const String login         = '/login';
  static const String shell         = '/shell';
  static const String recorder      = '/recorder';
  static const String notesViewer   = '/notes';
  static const String syllabus      = '/syllabus';
  static const String masterProfile = '/career/profile';
  static const String jdInput       = '/career/jd';
  static const String optimization  = '/career/result';

  static Route<dynamic> generateRoute(RouteSettings s) {
    switch (s.name) {
      case login:         return _r(const LoginScreen());
      case shell:         return _r(const MainShell());
      case recorder:      return _r(const RecorderScreen());
      case notesViewer:   return _r(NotesViewerScreen(lectureId: s.arguments as String));
      case syllabus:      return _r(const SyllabusTrackerScreen());
      case masterProfile: return _r(const MasterProfileScreen());
      case jdInput:       return _r(const JdInputScreen());
      case optimization:  return _r(const OptimizationViewScreen());
      default:            return _r(const MainShell());
    }
  }

  static MaterialPageRoute _r(Widget w) => MaterialPageRoute(builder: (_) => w);
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        if (auth.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (auth.user == null) return const LoginScreen();
        return const MainShell();
      },
    );
  }
}