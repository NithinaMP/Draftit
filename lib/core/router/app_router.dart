import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/1_voice_to_notes/presentation/dashboard_screen.dart';
import '../../features/1_voice_to_notes/presentation/recorder_screen.dart';
import '../../features/1_voice_to_notes/presentation/notes_viewer_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String recorder = '/recorder';
  static const String notesViewer = '/notes';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case recorder:
        return MaterialPageRoute(builder: (_) => const RecorderScreen());
      case notesViewer:
        final lectureId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => NotesViewerScreen(lectureId: lectureId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}

/// Auth guard widget — redirects based on auth state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (auth.user == null) {
          return const LoginScreen();
        }
        return const DashboardScreen();
      },
    );
  }
}