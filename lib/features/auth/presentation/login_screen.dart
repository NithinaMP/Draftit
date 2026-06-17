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
  // Mode: 'login' | 'register'
  String _mode = 'login';

  // Controllers
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _passCtrl      = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  final _formKey        = GlobalKey<FormState>();

  // Visibility toggles
  bool _obscurePass    = true;
  bool _obscureConfirm = true;

  // Animation
  late final AnimationController _floatCtrl;
  late final AnimationController _fadeCtrl;
  late final AnimationController _shakeCtrl;
  late final Animation<double> _floatAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _fadeCtrl.dispose();
    _shakeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _switchMode(String mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    context.read<AuthProvider>().clearError();
    _fadeCtrl.forward(from: 0);
  }

  void _showForgotPassword(BuildContext context) {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    bool sent = false;
    String? error;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppTheme.surfaceOf(context),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setModal) => Padding(
                padding: EdgeInsets.only(
                    left: 24, right: 24, top: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 32),
                child: Column(mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                      color: AppTheme.borderOf(context),
                      borderRadius: BorderRadius.circular(2)),
                )),
            if (sent) ...[
    Center(child: Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
    color: AppTheme.success.withOpacity(0.1),
    shape: BoxShape.circle),
    child: const Icon(Icons.mark_email_read_rounded,
    color: AppTheme.success, size: 40),
    )),
    const SizedBox(height: 20),
    Center(child: Text('Email Sent!',
    style: GoogleFonts.playfairDisplay(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppTheme.textPrimaryOf(context)))),
    const SizedBox(height: 8),
    Center(child: Text(
    'A password reset link has been sent to\n${emailCtrl.text.trim()}\n\nCheck your inbox and spam folder.',
    textAlign: TextAlign.center,
    style: GoogleFonts.dmSans(
    fontSize: 14, color: AppTheme.textSecondaryOf(context), height: 1.6),
    )),
    const SizedBox(height: 24),
    GradientButton(
    label: 'Back to Sign In',
    icon: Icons.login_rounded,
    onPressed: () => Navigator.pop(ctx),
    ),
    ] else ...[
    Text('Reset Password',
    style: GoogleFonts.playfairDisplay(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppTheme.textPrimaryOf(context))),
    const SizedBox(height: 8),
    Text(
    'Enter your email address and we will send you a link to reset your password.',
    style: GoogleFonts.dmSans(
    fontSize: 14, color: AppTheme.textSecondaryOf(context), height: 1.5),
    ),
    const SizedBox(height: 24),
    if (error != null)
    Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: AppTheme.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(10)),
    child: Row(children: [
    const Icon(Icons.error_outline_rounded,
    color: AppTheme.error, size: 16),
    const SizedBox(width: 8),
    Expanded(child: Text(error!,
    style: const TextStyle(color: AppTheme.error, fontSize: 13))),
    ]),
    ),
    TextFormField(
    controller: emailCtrl,
    keyboardType: TextInputType.emailAddress,
    style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
    decoration: const InputDecoration(
    labelText: 'Email address',
    prefixIcon: Icon(Icons.email_outlined, size: 20),
    ),
    ),
    const SizedBox(height: 24),
    Consumer<AuthProvider>(
    builder: (_, auth, __) => GradientButton(
    label: 'Send Reset Link',
    icon: Icons.send_rounded,
    isLoading: auth.status == AuthStatus.loading,
    onPressed: () async {
    if (emailCtrl.text.trim().isEmpty) {
    setModal(() => error = 'Please enter your email address.');
    return;
    }
    if (!emailCtrl.text.contains('@')) {
    setModal(() => error = 'Please enter a valid email address.');
    return;
    }
    final ok = await auth.sendPasswordResetEmail(
    emailCtrl.text.trim());
    if (ok) {
    setModal(() => sent = true);
    } else {
    setModal(() => error = auth.errorMessage);
    }
    },
    ),
    ),
    ],
    ]),
    ),
    ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      _shakeCtrl.forward(from: 0);
      return;
    }

    final auth = context.read<AuthProvider>();
    bool success;

    if (_mode == 'login') {
      success = await auth.signInWithEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
    } else {
      success = await auth.registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
    }

    if (!success && mounted) {
      _shakeCtrl.forward(from: 0);
    }
  }

  Future<void> _handleGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!success && mounted && auth.errorMessage != null) {
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: Stack(
        children: [
          // Ambient orbs
          Positioned(
              top: -120, right: -80,
              child: _Orb(size: 300, color: AppTheme.accent.withOpacity(0.1))),
          Positioned(
              bottom: -80, left: -60,
              child: _Orb(size: 250, color: const Color(0xFF9D40FF).withOpacity(0.08))),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // Tab switcher at top
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _ModeSelector(
                      current: _mode,
                      onSelect: _switchMode,
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),

                          // Floating logo
                          AnimatedBuilder(
                            animation: _floatAnim,
                            builder: (_, child) => Transform.translate(
                              offset: Offset(0, _floatAnim.value),
                              child: child,
                            ),
                            child: const _DraftItLogo(),
                          ),

                          const SizedBox(height: 36),

                          // Headline
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey(_mode),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _mode == 'login'
                                      ? 'Welcome\nback.'
                                      : 'Create your\naccount.',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimaryOf(context),
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _mode == 'login'
                                      ? 'Your notes, skills and career progress await.'
                                      : 'Start your journey from classroom to career.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(color: AppTheme.textSecondaryOf(context)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Error banner
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) {
                              if (auth.errorMessage == null) {
                                return const SizedBox.shrink();
                              }
                              return AnimatedBuilder(
                                animation: _shakeAnim,
                                builder: (_, child) => Transform.translate(
                                  offset: Offset(
                                    8 * _shakeAnim.value *
                                        (1 - _shakeAnim.value) *
                                        (0.5 - _shakeAnim.value).sign,
                                    0,
                                  ),
                                  child: child,
                                ),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppTheme.error.withOpacity(0.35)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.error_outline_rounded,
                                          color: AppTheme.error, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          auth.errorMessage!,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 13,
                                            color: AppTheme.error,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: auth.clearError,
                                        child: const Icon(Icons.close_rounded,
                                            color: AppTheme.error, size: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Name field — only on register
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: _mode == 'register'
                                      ? Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _FormField(
                                      controller: _nameCtrl,
                                      label: 'Full Name',
                                      hint: 'Enter',
                                      icon: Icons.person_outline_rounded,
                                      validator: (v) {
                                        if (v == null || v.trim().isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        if (v.trim().length < 2) {
                                          return 'Name must be at least 2 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                ),

                                // Email
                                _FormField(
                                  controller: _emailCtrl,
                                  label: 'Email address',
                                  hint: 'you@example.com',
                                  icon: Icons.email_outlined,
                                  type: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!v.contains('@') || !v.contains('.')) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Password
                                _PasswordField(
                                  controller: _passCtrl,
                                  label: 'Password',
                                  obscure: _obscurePass,
                                  onToggle: () =>
                                      setState(() => _obscurePass = !_obscurePass),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (v.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    if (_mode == 'register') {
                                      if (!v.contains(RegExp(r'[A-Z]')) &&
                                          !v.contains(RegExp(r'[0-9]'))) {
                                        return 'Include at least one number or uppercase letter';
                                      }
                                    }
                                    return null;
                                  },
                                ),

                                // Forgot password — only on login
                                if (_mode == 'login')
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: GestureDetector(
                                      onTap: () => _showForgotPassword(context),
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          'Forgot Password?',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.accentLight,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Confirm password — only on register
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: _mode == 'register'
                                      ? Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _PasswordField(
                                      controller: _confirmCtrl,
                                      label: 'Confirm Password',
                                      obscure: _obscureConfirm,
                                      onToggle: () => setState(
                                              () => _obscureConfirm =
                                          !_obscureConfirm),
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (v != _passCtrl.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Submit button
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => GradientButton(
                              label: _mode == 'login' ? 'Sign In' : 'Create Account',
                              icon: _mode == 'login'
                                  ? Icons.login_rounded
                                  : Icons.person_add_outlined,
                              isLoading: auth.status == AuthStatus.loading,
                              onPressed: _handleSubmit,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Divider
                          Row(children: [
                             Expanded(child: Divider(color: AppTheme.borderOf(context))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text('or continue with',
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ),
                             Expanded(child: Divider(color: AppTheme.borderOf(context))),
                          ]),

                          const SizedBox(height: 20),

                          // Google Sign-In
                          Consumer<AuthProvider>(
                            builder: (_, auth, __) => _GoogleButton(
                              isLoading: auth.status == AuthStatus.loading,
                              onPressed: _handleGoogle,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Password strength indicator (register only)
                          if (_mode == 'register')
                            _PasswordStrengthBar(controller: _passCtrl),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mode Selector (Login / Register tabs) ────────────────────────────────────
class _ModeSelector extends StatelessWidget {
  final String current;
  final Function(String) onSelect;
  const _ModeSelector({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Row(children: [
        _Tab(label: 'Sign In', active: current == 'login',
            onTap: () => onSelect('login')),
        _Tab(label: 'Register', active: current == 'register',
            onTap: () => onSelect('register')),
      ]),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF9D40FF)])
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : AppTheme.textSecondaryOf(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── DraftIt Logo ─────────────────────────────────────────────────────────────
class _DraftItLogo extends StatelessWidget {
  const _DraftItLogo();

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 52,
        height: 52,
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
        clipBehavior: Clip.antiAlias,
        child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
        // child: const Icon(Icons.edit_note_rounded,
        //     color: Colors.white, size: 28),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DraftIt',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryOf(context),
            )),
        Text('From Classroom to Career',
            style: GoogleFonts.dmSans(
                fontSize: 11, color: AppTheme.textSecondaryOf(context))),
      ]),
    ]);
  }
}

// ─── Form Field ───────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType type;
  final String? Function(String?) validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.type = TextInputType.text,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }
}

// ─── Password Field ───────────────────────────────────────────────────────────
class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final String? Function(String?) validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style:  TextStyle(color: AppTheme.textPrimaryOf(context)),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: AppTheme.textSecondaryOf(context),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// ─── Password Strength Bar ────────────────────────────────────────────────────
class _PasswordStrengthBar extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordStrengthBar({required this.controller});

  @override
  State<_PasswordStrengthBar> createState() => _PasswordStrengthBarState();
}

class _PasswordStrengthBarState extends State<_PasswordStrengthBar> {
  String _password = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() => _password = widget.controller.text);
    });
  }

  int get _strength {
    if (_password.isEmpty) return 0;
    int score = 0;
    if (_password.length >= 6) score++;
    if (_password.length >= 10) score++;
    if (_password.contains(RegExp(r'[A-Z]'))) score++;
    if (_password.contains(RegExp(r'[0-9]'))) score++;
    if (_password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score++;
    return score;
  }

  String get _label =>
      ['', 'Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong'][_strength];

  Color get _color => [
    AppTheme.borderOf(context),
    AppTheme.error,
    AppTheme.amber,
    AppTheme.amber,
    AppTheme.success,
    AppTheme.success,
  ][_strength];

  @override
  Widget build(BuildContext context) {
    if (_password.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Password Strength',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12, color: AppTheme.textSecondaryOf(context))),
            Text(_label,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _color)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 4,
                margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < _strength ? _color : AppTheme.borderOf(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
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
          side:  BorderSide(color: AppTheme.borderOf(context)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          backgroundColor: AppTheme.surfaceOf(context),
        ),
        child: isLoading
            ? const SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(
                color: AppTheme.accent, strokeWidth: 2.5))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          // Google G coloured icon
          _GoogleG(),
          const SizedBox(width: 12),
          Text('Continue with Google',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryOf(context),
              )),
        ]),
      ),
    );
  }
}

class _GoogleG extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    void arc(double start, double sweep, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.72),
          start, sweep, false, paint);
    }

    // Blue arc (right)
    arc(-0.52, 1.57, const Color(0xFF4285F4));
    // Red arc (top)
    arc(1.05, 1.57, const Color(0xFFEA4335));
    // Yellow arc (bottom-left)
    arc(2.62, 1.05, const Color(0xFFFBBC05));
    // Green arc (bottom-right to right)
    arc(3.67, 0.82, const Color(0xFF34A853));

    // Horizontal bar for the "G"
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r * 0.72, cy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Orb ──────────────────────────────────────────────────────────────────────
class _Orb extends StatelessWidget {
  final double size;
  final Color color;
  const _Orb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: size * 0.5)],
      ),
    );
  }
}