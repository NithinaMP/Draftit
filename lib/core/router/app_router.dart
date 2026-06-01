import 'package:flutter/material.dart';
import '../../features/1_voice_to_notes/presentation/recorder_screen.dart';
import '../../features/1_voice_to_notes/presentation/notes_viewer_screen.dart';
import '../../features/2_study_buddy/presentation/screens/syllabus_tracker_screen.dart';
import '../../features/3_career_builder/presentation/screens/master_profile_screen.dart';
import '../../features/3_career_builder/presentation/screens/jd_input_screen.dart';
import '../../features/3_career_builder/presentation/screens/optimization_view_screen.dart';

class AppRouter {
  static const String recorder      = '/recorder';
  static const String notesViewer   = '/notes';
  static const String syllabus      = '/syllabus';
  static const String masterProfile = '/career/profile';
  static const String jdInput       = '/career/jd';
  static const String optimization  = '/career/result';

  static Route<dynamic> generateRoute(RouteSettings s) {
    switch (s.name) {
      case recorder:
        return _r(const RecorderScreen());
      case notesViewer:
        return _r(NotesViewerScreen(lectureId: s.arguments as String));
      case syllabus:
        return _r(const SyllabusTrackerScreen());
      case masterProfile:
        return _r(const MasterProfileScreen());
      case jdInput:
        return _r(const JdInputScreen());
      case optimization:
        return _r(const OptimizationViewScreen());
      default:
        return _r(const Scaffold(
          body: Center(child: Text('Route not found')),
        ));
    }
  }

  static MaterialPageRoute _r(Widget w) =>
      MaterialPageRoute(builder: (_) => w);
}