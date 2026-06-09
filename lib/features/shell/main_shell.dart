import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../1_voice_to_notes/presentation/dashboard_screen.dart';
import '../2_study_buddy/presentation/screens/study_buddy_screen.dart';
import '../3_career_builder/presentation/screens/career_builder_screen.dart';
import '../settings/settings_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  DateTime? _lastBackPressed;

  // Keep all screens alive with IndexedStack
  final List<Widget> _screens = const [
    DashboardScreen(),
    StudyBuddyScreen(),
    CareerBuilderScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async{
        if (didPop) return;
        // If not on Dashboard, go to Dashboard

        if (_currentIndex != 0){
          setState(() {
            _currentIndex = 0;
          });
          return;
        }
        // Double back to exit

        final now = DateTime.now();

        if (_lastBackPressed == null || now.difference(_lastBackPressed!)>
        const Duration(seconds: 2)){
          _lastBackPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
          ),);
          return;
        }

        SystemNavigator.pop();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: isDark ? AppTheme.bg : AppTheme.bgLight,
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: _BottomNav(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDark;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Notes'),
    _NavItem(icon: Icons.psychology_outlined, activeIcon: Icons.psychology_rounded, label: 'Exam AI'),
    _NavItem(icon: Icons.work_outline_rounded, activeIcon: Icons.work_rounded, label: 'Career'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? AppTheme.surfaceOf(context) : AppTheme.surfaceLight;
    final border = isDark ? AppTheme.borderOf(context) : AppTheme.borderLight;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? AppTheme.accent.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            active ? item.activeIcon : item.icon,
                            key: ValueKey(active),
                            color: active
                                ? AppTheme.accent
                                : isDark
                                ? AppTheme.textSecondaryOf(context)
                                : AppTheme.textSecondaryLight,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: active
                                ? AppTheme.accent
                                : isDark
                                ? AppTheme.textSecondaryOf(context)
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}