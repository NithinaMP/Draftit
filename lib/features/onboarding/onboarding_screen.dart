import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  static const _totalPages = 3;

  late final List<AnimationController> _animCtrls;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  @override
  void initState() {
    super.initState();
    _animCtrls = List.generate(
      _totalPages,
          (_) => AnimationController(
          vsync: this, duration: const Duration(milliseconds: 700)),
    );
    _fadeAnims = _animCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slideAnims = _animCtrls
        .map((c) => Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _animCtrls[0].forward();
  }

  @override
  void dispose() {
    for (final c in _animCtrls) {
      c.dispose();
    }
    _pageCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await OnboardingService.instance.markOnboardingDone();
    if (mounted) widget.onDone();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _animCtrls[page].forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accent.withOpacity(isDark ? 0.09 : 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF9D40FF)
                    .withOpacity(isDark ? 0.07 : 0.05),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 20, 0),
                    child: TextButton(
                      onPressed: _finish,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryOf(context),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageCtrl,
                    onPageChanged: _onPageChanged,
                    children: [
                      _WelcomePage(
                          fadeAnim: _fadeAnims[0], slideAnim: _slideAnims[0]),
                      _FeaturesPage(
                          fadeAnim: _fadeAnims[1], slideAnim: _slideAnims[1]),
                      _ActionPage(
                          fadeAnim: _fadeAnims[2], slideAnim: _slideAnims[2]),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_totalPages, (i) {
                          final active = i == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: active
                                  ? AppTheme.accent
                                  : AppTheme.accent.withOpacity(0.25),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accent, Color(0xFF9D40FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage == _totalPages - 1
                                      ? 'Start Recording'
                                      : 'Next',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_currentPage == _totalPages - 1) ...[
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: _finish,
                          child: Text(
                            "I'll explore on my own",
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppTheme.textSecondaryOf(context),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 1: Welcome ───────────────────────────────────────────────────────────
class _WelcomePage extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  const _WelcomePage({required this.fadeAnim, required this.slideAnim});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _PulsingLogo(),
              const SizedBox(height: 48),
              Text(
                'Your lectures deserve\nbetter than messy notes.',
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(context),
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'DraftIt turns what you hear into\nwhat you need — from class to career.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: AppTheme.textSecondaryOf(context),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page 2: Features ──────────────────────────────────────────────────────────
class _FeaturesPage extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  const _FeaturesPage({required this.fadeAnim, required this.slideAnim});

  static final _features = [
    (
    icon: Icons.mic_rounded,
    color: AppTheme.accent,
    title: 'Record. Read. Remember.',
    desc:
    'Speak your lecture — get structured notes, AI summaries, and extracted skills in seconds.',
    ),
    (
    icon: Icons.psychology_rounded,
    color: AppTheme.amber,
    title: "Know what's coming.",
    desc:
    'Generate 2, 5 & 10 mark exam questions from your own notes. Practice answers with AI feedback.',
    ),
    (
    icon: Icons.work_outline_rounded,
    color: const Color(0xFF00C9FF),
    title: 'Your resume, rewritten.',
    desc:
    'Paste any job description. Get an ATS-optimized, skill-matched resume in under 60 seconds.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Everything you need.',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Three powerful tools. One app.',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.textSecondaryOf(context),
                ),
              ),
              const SizedBox(height: 32),
              ..._features.map((f) => _FeatureCard(
                icon: f.icon,
                color: f.color,
                title: f.title,
                desc: f.desc,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppTheme.textSecondaryOf(context),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Action ────────────────────────────────────────────────────────────
class _ActionPage extends StatelessWidget {
  final Animation<double> fadeAnim;
  final Animation<Offset> slideAnim;
  const _ActionPage({required this.fadeAnim, required this.slideAnim});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(0.1),
                  border: Border.all(
                      color: AppTheme.accent.withOpacity(0.3), width: 2),
                ),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.accent, Color(0xFF9D40FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic_rounded,
                      color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Ready to start?',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Record your first lecture and watch\nDraftIt turn it into structured notes,\nexam questions, and career fuel.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppTheme.textSecondaryOf(context),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pulsing logo ──────────────────────────────────────────────────────────────
class _PulsingLogo extends StatefulWidget {
  const _PulsingLogo();

  @override
  State<_PulsingLogo> createState() => _PulsingLogoState();
}

class _PulsingLogoState extends State<_PulsingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: 100,
        height: 100,
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
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 52,
            ),
          ),
        ),
      ),
    );
  }
}