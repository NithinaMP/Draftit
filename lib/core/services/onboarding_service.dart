import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for onboarding + tooltip state.
///
/// Why a ChangeNotifier singleton instead of plain static methods:
/// Tooltips need to disappear the instant they're dismissed, even if the
/// dismiss happens on a totally different screen than where the tooltip
/// is rendered. A plain SharedPreferences check only runs once in
/// initState(), so a tooltip would stay visible until the next full
/// screen rebuild. By keeping an in-memory cache here and calling
/// notifyListeners() on every change, every tooltip widget listening
/// to this service updates in the same frame the dismiss happens —
/// with zero rebuild-on-navigation required.
class OnboardingService extends ChangeNotifier {
  OnboardingService._internal();
  static final OnboardingService instance = OnboardingService._internal();

  // ── Keys ───────────────────────────────────────────────────────────────────
  static const _keyOnboardingDone = 'onboarding_done';

  static const String tooltipDashboard = 'tooltip_dashboard_mic';
  static const String tooltipExam      = 'tooltip_exam_lecture_select';
  static const String tooltipCareer    = 'tooltip_career_profile_banner';
  static const String tooltipJd        = 'tooltip_jd_paste_field';

  // ── In-memory state ───────────────────────────────────────────────────────
  final Set<String> _seenTooltips = {};
  bool _onboardingDone = false;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  bool get onboardingDone => _onboardingDone;

  /// Call once at app startup, before runApp(). Loads all flags from
  /// SharedPreferences into memory so every later check is synchronous
  /// and instant — no async gap, no flicker.
  Future<void> init() async {
    if (_isLoaded) return;
    final prefs = await SharedPreferences.getInstance();
    _onboardingDone = prefs.getBool(_keyOnboardingDone) ?? false;
    for (final key in [
      tooltipDashboard,
      tooltipExam,
      tooltipCareer,
      tooltipJd,
    ]) {
      if (prefs.getBool(key) ?? false) _seenTooltips.add(key);
    }
    _isLoaded = true;
    notifyListeners();
  }

  /// Synchronous, instant — safe to call directly in build().
  bool hasSeenTooltip(String key) => _seenTooltips.contains(key);

  /// Marks a tooltip seen permanently. Updates memory + notifies all
  /// listeners FIRST (instant visual hide), then persists to disk in
  /// the background. Once called, this tooltip never shows again —
  /// on this screen, on any other screen, or after app restart.
  Future<void> markTooltipSeen(String key) async {
    if (_seenTooltips.contains(key)) return;
    _seenTooltips.add(key);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  Future<void> markOnboardingDone() async {
    if (_onboardingDone) return;
    _onboardingDone = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }

  /// Testing/debug helper — resets all onboarding state.
  /// Not called anywhere in production code paths.
  Future<void> resetAll() async {
    _seenTooltips.clear();
    _onboardingDone = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingDone);
    await prefs.remove(tooltipDashboard);
    await prefs.remove(tooltipExam);
    await prefs.remove(tooltipCareer);
    await prefs.remove(tooltipJd);
  }
}