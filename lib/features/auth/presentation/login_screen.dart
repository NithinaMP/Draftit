import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePass = true;

  late final AnimationController _floatCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _floatAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    bool success;
    if (_isRegisterMode) {
      success = await auth.registerWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
    } else {
      success = await auth.signInWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Something went wrong'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _handleGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!success && mounted && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage!),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ambient background orbs
          Positioned(
            top: -100,
            right: -80,
            child: _BackgroundOrb(
              size: 300,
              color: AppTheme.accent.withOpacity(0.12),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: _BackgroundOrb(
              size: 250,
              color: const Color(0xFF9D40FF).withOpacity(0.1),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // Animated logo
                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      ),
                      child: _Logo(),
                    ),

                    const SizedBox(height: 48),

                    // Headline
                    Text(
                      _isRegisterMode ? 'Create your\naccount.' : 'Welcome\nback.',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRegisterMode
                          ? 'Start your journey from classroom to career.'
                          : 'Your notes, skills, and career progress await.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(Icons.mail_outline, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter your email';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon:
                              const Icon(Icons.lock_outline, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Enter your password';
                              if (_isRegisterMode && v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Email submit button
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => GradientButton(
                        label: _isRegisterMode ? 'Create Account' : 'Sign In',
                        isLoading: auth.status == AuthStatus.loading,
                        onPressed: _handleEmailAuth,
                        icon: _isRegisterMode
                            ? Icons.person_add_outlined
                            : Icons.login_outlined,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(children: [
                      const Expanded(child: Divider(color: AppTheme.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const Expanded(child: Divider(color: AppTheme.border)),
                    ]),

                    const SizedBox(height: 20),

                    // Google button
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) => _GoogleButton(
                        isLoading: auth.status == AuthStatus.loading,
                        onPressed: _handleGoogle,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Toggle register / login
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isRegisterMode = !_isRegisterMode);
                          context.read<AuthProvider>().clearError();
                        },
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: [
                              TextSpan(
                                text: _isRegisterMode
                                    ? 'Already have an account? '
                                    : "Don't have an account? ",
                              ),
                              TextSpan(
                                text: _isRegisterMode ? 'Sign In' : 'Register',
                                style: GoogleFonts.spaceGrotesk(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accentLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Logo Widget ──────────────────────────────────────────────────────────────
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accent, Color(0xFF9D40FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        Text(
          'DraftIt',
          style: GoogleFonts.playfairDisplay(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── Google Button ────────────────────────────────────────────────────────────
class _GoogleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _GoogleButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppTheme.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: AppTheme.textPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G icon using colored text
            Text(
              'G',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF4285F4),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Continue with Google',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Background Orb ───────────────────────────────────────────────────────────
class _BackgroundOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 0.5,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }
}