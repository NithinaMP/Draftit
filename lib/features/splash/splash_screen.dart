import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_info.dart';
import '../../main.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/presentation/login_screen.dart';
import '../shell/main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _orbCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _orbScale;
  late final Animation<double> _exitOpacity;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(
        begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _taglineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));
    _taglineSlide = Tween<Offset>(
        begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));

    _orbCtrl = AnimationController(
        vsync: this, duration:
    // const Duration(milliseconds: 1500)
    const Duration(seconds: 1)
    )
      ..repeat(reverse: true);
    _orbScale = Tween<double>(begin: 0.85, end: 1.15).animate(
        CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));

    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 100));
    await _taglineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1000));//1400
    await _exitCtrl.forward();
    if (mounted) _navigate();
  }

  void _navigate() {
    final auth = context.read<AuthProvider>();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppBootstrap(),
        // auth.user != null ? const MainShell() : const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),//400
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _taglineCtrl.dispose();
    _orbCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitOpacity,
      builder: (_, child) =>
          Opacity(opacity: _exitOpacity.value, child: child),
      child: Scaffold(
        backgroundColor: AppTheme.bgOf(context),
        body: Stack(children: [
          // Ambient orbs
          AnimatedBuilder(
            animation: _orbScale,
            builder: (_, __) => Stack(children: [
              Positioned(
                top: -100, right: -80,
                child: Transform.scale(
                  scale: _orbScale.value,
                  child: Container(
                    width: 320, height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accent.withOpacity(0.12),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -80, left: -60,
                child: Transform.scale(
                  scale: 2.0 - _orbScale.value,
                  child: Container(
                    width: 260, height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF9D40FF).withOpacity(0.1),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.38,
                left: MediaQuery.of(context).size.width * 0.55,
                child: Transform.scale(
                  scale: _orbScale.value * 0.7,
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.amber.withOpacity(0.07),
                    ),
                  ),
                ),
              ),
            ]),
          ),

          // Centre content
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Logo
              AnimatedBuilder(
                animation: _logoCtrl,
                builder: (_, __) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accent, Color(0xFF9D40FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.45),
                            blurRadius: 40,
                            spreadRadius: 4,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                      // child: const Icon(Icons.edit_note_rounded,
                      //     color: Colors.white, size: 52),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // App name with gradient
              AnimatedBuilder(
                animation: _textCtrl,
                builder: (_, __) => FadeTransition(
                  opacity: _textOpacity,
                  child: SlideTransition(
                    position: _textSlide,
                    child: ShaderMask(
                      shaderCallback: (bounds) =>  LinearGradient(
                        colors: [AppTheme.textPrimaryOf(context), AppTheme.accentLight],
                      ).createShader(bounds),
                      child: Text('DraftIt',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          )),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              AnimatedBuilder(
                animation: _taglineCtrl,
                builder: (_, __) => FadeTransition(
                  opacity: _taglineOpacity,
                  child: SlideTransition(
                    position: _taglineSlide,
                    child: Text(
                      'From Classroom to Career,\nOne Draft at a Time.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: AppTheme.textSecondaryOf(context),
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),

          // Bottom — loading dots + version
          Positioned(
            bottom: 48, left: 0, right: 0,
            child: AnimatedBuilder(
              animation: _taglineOpacity,
              builder: (_, __) => Opacity(
                opacity: _taglineOpacity.value,
                child: Column(children: [
                  const _LoadingDots(),
                  const SizedBox(height: 16),
                  Text('v${AppInfo.version}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context).withOpacity(0.5),
                        letterSpacing: 1,
                      )),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Animated loading dots ────────────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        3,
            (i) => AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 400))); //600
    _anims = _ctrls
        .map((c) => Tween<double>(begin: 0.25, end: 1.0).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
    _startLoop();
  }

  // Future<void> _startLoop() async {
  //   while (mounted) {
  //     for (int i = 0; i < 3; i++) {
  //       if (!mounted) return;
  //       _ctrls[i].forward();
  //       await Future.delayed(const Duration(milliseconds: 160));
  //     }
  //     await Future.delayed(const Duration(milliseconds: 300));
  //     for (final c in _ctrls) c.reverse();
  //     await Future.delayed(const Duration(milliseconds: 500));
  //   }
  // }
  Future<void> _startLoop() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        _ctrls[i].forward();
        await Future.delayed(const Duration(milliseconds: 160));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      // Check mounted before reverse — fixes dispose crash
      if (!mounted) return;
      for (final c in _ctrls) {
        if (c.isAnimating || c.value > 0) c.reverse();
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
            (i) => AnimatedBuilder(
          animation: _anims[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accent.withOpacity(_anims[i].value),
            ),
          ),
        ),
      ),
    );
  }
}