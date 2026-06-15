
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_widgets.dart';
import '../auth/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgOf(context),
      body: SafeArea(
        child: Consumer2<AuthProvider, ThemeProvider>(
          builder: (_, auth, themeProvider, __) {
            final isDark = themeProvider.isDark;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text('Settings',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryOf(context),

                        )),
                  ),
                ),

                // ── Account card ──
                SliverToBoxAdapter(child: _AccountCard(auth: auth)),

                // ── Appearance ──
                SliverToBoxAdapter(child: _SectionLabel(label: 'Appearance')),
                SliverToBoxAdapter(
                  child: _SettingsCard(children: [
                    _ThemeToggle(themeProvider: themeProvider, isDark: isDark),
                  ]),
                ),

                // ── Account actions ──
                SliverToBoxAdapter(child: _SectionLabel(label: 'Account')),
                SliverToBoxAdapter(
                  child: _SettingsCard(children: [
                    if (!auth.isGoogleUser)
                      _ActionTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change Password',
                        color: AppTheme.accent,
                        onTap: () => _showChangePassword(context, auth),
                      ),
                    // if (!auth.isGoogleUser)
                    //   _Divider(),
                    // if (!auth.isGoogleUser)
                    //   _ActionTile(
                    //     icon: Icons.email_outlined,
                    //     label: 'Reset via Email',
                    //     color: AppTheme.accentLight,
                    //     onTap: () => _showResetEmail(context, auth),
                    //   ),
                    if (!auth.isGoogleUser)
                      _Divider(),
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      color: AppTheme.error,
                      onTap: () => _confirmSignOut(context, auth),
                    ),
                    _Divider(),
                    _ActionTile(
                      icon: Icons.delete_forever_rounded,
                      label: 'Delete Account',
                      color: AppTheme.error,
                      onTap: () => _confirmDelete(context, auth),
                    ),
                  ]),
                ),

                // ── About ──
                SliverToBoxAdapter(child: _SectionLabel(label: 'About')),
                SliverToBoxAdapter(
                  child: _SettingsCard(children: [
                    _InfoTile(icon: Icons.info_outline_rounded,
                        label: 'App Version', value: '1.0.0'),
                    _Divider(),
                    _InfoTile(icon: Icons.edit_note_rounded,
                        label: 'DraftIt', value: 'From Classroom to Career'),
                    _Divider(),
                    _InfoTile(icon: Icons.rocket_launch_outlined,
                        label: 'Powered by', value: 'DraftIt AI'),
                  ]),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }



  // ── Sign Out confirmation ──────────────────────────────────────────────────
  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: AppTheme.borderOf(context),
                  borderRadius: BorderRadius.circular(2))),
          Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 32)),
          const SizedBox(height: 16),
          Text('Sign Out?', style: GoogleFonts.playfairDisplay(
              fontSize: 24, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryOf(context))),
          const SizedBox(height: 8),
          Text("You'll need to sign in again to access your data.",
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14,
                  color: AppTheme.textSecondaryOf(context), height: 1.5)),
          const SizedBox(height: 28),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.borderOf(context)),
                  foregroundColor: AppTheme.textSecondaryOf(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14)),
              child: Text('Cancel', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await auth.signOut();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error, foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0),
              child: Text('Sign Out', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }

  // ── Change Password ───────────────────────────────────────────────────────
  void _showResetEmail(BuildContext context, AuthProvider auth) {
    final email = auth.user?.email ?? '';
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
                  Center(child: Text('Reset Email Sent!',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryOf(context)))),
                  const SizedBox(height: 8),
                  Center(child: Text(
                    'A reset link was sent to\n$email\n\nCheck your inbox and spam folder.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 14,
                        color: AppTheme.textSecondaryOf(context), height: 1.6),
                  )),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    child: Text('Done',
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
                  ),
                ] else ...[
                  Text('Reset via Email',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimaryOf(context))),
                  const SizedBox(height: 8),
                  Text(
                    'We will send a password reset link to:\n$email',
                    style: GoogleFonts.dmSans(fontSize: 14,
                        color: AppTheme.textSecondaryOf(context), height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  if (error != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(error!,
                          style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                    ),
                  Consumer<AuthProvider>(
                    builder: (_, a, __) => GradientButton(
                      label: 'Send Reset Link',
                      icon: Icons.send_rounded,
                      isLoading: a.status == AuthStatus.loading,
                      onPressed: () async {
                        final ok = await a.sendPasswordResetEmail(email);
                        if (ok) {
                          setModal(() => sent = true);
                        } else {
                          setModal(() => error = a.errorMessage);
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

  void _showChangePassword(BuildContext context, AuthProvider auth) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? localError;
    bool success = false;

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
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: AppTheme.borderOf(context),
                        borderRadius: BorderRadius.circular(2)))),
                Text('Change Password', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 20),
                if (success)
                  Container(margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 18),
                        const SizedBox(width: 8),
                        Text('Password changed successfully!',
                            style: GoogleFonts.spaceGrotesk(color: AppTheme.success, fontWeight: FontWeight.w600)),
                      ]))
                else ...[
                  if (localError != null)
                    Container(margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(localError!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                  _pwField(ctx, currentCtrl, 'Current Password', obscureCurrent,
                          () => setModal(() => obscureCurrent = !obscureCurrent)),
                  const SizedBox(height: 12),
                  _pwField(ctx, newCtrl, 'New Password', obscureNew,
                          () => setModal(() => obscureNew = !obscureNew)),
                  const SizedBox(height: 12),
                  _pwField(ctx, confirmCtrl, 'Confirm New Password', obscureConfirm,
                          () => setModal(() => obscureConfirm = !obscureConfirm)),
                  const SizedBox(height: 20),
                  Consumer<AuthProvider>(builder: (_, a, __) =>
                      GradientButton(
                        label: 'Update Password',
                        icon: Icons.lock_outline_rounded,
                        isLoading: a.status == AuthStatus.loading,
                        onPressed: () async {
                          setModal(() => localError = null);
                          if (newCtrl.text != confirmCtrl.text) {
                            setModal(() => localError = 'New passwords do not match.');
                            return;
                          }
                          if (newCtrl.text.length < 6) {
                            setModal(() => localError = 'New password must be at least 6 characters.');
                            return;
                          }
                          final ok = await a.changePassword(
                              currentPassword: currentCtrl.text,
                              newPassword: newCtrl.text);
                          if (ok) {
                            setModal(() => success = true);
                            Future.delayed(const Duration(seconds: 2),
                                    () => Navigator.pop(ctx));
                          } else {
                            setModal(() => localError = a.errorMessage);
                          }
                        },
                      )),
                ],
              ]),
        ),
      ),
    );
  }

  Widget _pwField(BuildContext ctx, TextEditingController ctrl, String label,
      bool obscure, VoidCallback onToggle) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: TextStyle(color: AppTheme.textPrimaryOf(ctx)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18, color: AppTheme.textSecondaryOf(ctx)),
          onPressed: onToggle,
        ),
      ),
    );
  }

  // ── Delete Account ────────────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, AuthProvider auth) {
    final passwordCtrl = TextEditingController();
    bool obscure = true;
    String? localError;

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
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: AppTheme.borderOf(context),
                        borderRadius: BorderRadius.circular(2)))),
                Center(child: Container(padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.delete_forever_rounded,
                        color: AppTheme.error, size: 32))),
                const SizedBox(height: 16),
                Center(child: Text('Delete Account',
                    style: GoogleFonts.playfairDisplay(fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimaryOf(context)))),
                const SizedBox(height: 8),
                Center(child: Text(
                    'This will permanently delete your account and all data. This cannot be undone.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 13,
                        color: AppTheme.textSecondaryOf(context), height: 1.5))),
                const SizedBox(height: 20),
                if (localError != null)
                  Container(margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(localError!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                if (!auth.isGoogleUser) ...[
                  TextField(
                    controller: passwordCtrl,
                    obscureText: obscure,
                    style: TextStyle(color: AppTheme.textPrimaryOf(context)),
                    decoration: InputDecoration(
                      labelText: 'Enter your password to confirm',
                      prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18, color: AppTheme.textSecondaryOf(context)),
                        onPressed: () => setModal(() => obscure = !obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.amber.withOpacity(0.3))),
                      child: Row(children: [
                        const Icon(Icons.info_outline_rounded, color: AppTheme.amber, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text('You will be asked to sign in with Google to confirm.',
                            style: GoogleFonts.dmSans(fontSize: 12,
                                color: AppTheme.textSecondaryOf(context)))),
                      ])),
                ],
                Row(children: [
                  Expanded(child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.borderOf(context)),
                        foregroundColor: AppTheme.textSecondaryOf(context),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: Text('Cancel',
                        style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: Consumer<AuthProvider>(builder: (_, a, __) =>
                      ElevatedButton(
                        onPressed: a.status == AuthStatus.loading ? null : () async {
                          setModal(() => localError = null);
                          if (!auth.isGoogleUser && passwordCtrl.text.isEmpty) {
                            setModal(() => localError = 'Please enter your password.');
                            return;
                          }
                          final ok = await a.deleteAccount(
                              password: passwordCtrl.text);
                          if (!ok && ctx.mounted) {
                            setModal(() => localError = a.errorMessage);
                          } else if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.error, foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14), elevation: 0),
                        child: a.status == AuthStatus.loading
                            ? const SizedBox(width: 20, height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Delete', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
                      ))),
                ]),
              ]),
        ),
      ),
    );
  }
}

// ─── Account Card ─────────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  final AuthProvider auth;
  const _AccountCard({required this.auth});

  @override
  Widget build(BuildContext context) {
    final isGoogle = auth.isGoogleUser;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.accent.withOpacity(0.12),
          const Color(0xFF9D40FF).withOpacity(0.08),
        ]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
      ),
      child: Row(children: [
        // Avatar with initials
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF9D40FF)]),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.3),
                blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Center(child: Text(auth.initials,
              style: GoogleFonts.spaceGrotesk(fontSize: 20,
                  fontWeight: FontWeight.w800, color: Colors.white))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(auth.displayName.isNotEmpty ? auth.displayName : 'DraftIt User',
              style: GoogleFonts.spaceGrotesk(fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryOf(context))),
          const SizedBox(height: 3),
          Text(auth.user?.email ?? '',
              style: GoogleFonts.dmSans(fontSize: 13,
                  color: AppTheme.textSecondaryOf(context))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isGoogle
                  ? const Color(0xFF4285F4).withOpacity(0.12)
                  : AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(isGoogle ? Icons.g_mobiledata_rounded : Icons.email_outlined,
                  size: 13,
                  color: isGoogle ? const Color(0xFF4285F4) : AppTheme.accentLight),
              const SizedBox(width: 4),
              Text(isGoogle ? 'Google Account' : 'Email Account',
                  style: GoogleFonts.spaceGrotesk(fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isGoogle
                          ? const Color(0xFF4285F4) : AppTheme.accentLight)),
            ]),
          ),
        ])),
      ]),
    );
  }
}

// ─── Theme Toggle ─────────────────────────────────────────────────────────────
class _ThemeToggle extends StatelessWidget {
  final ThemeProvider themeProvider;
  final bool isDark;
  const _ThemeToggle({required this.themeProvider, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: AppTheme.amber, size: 20)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Theme', style: GoogleFonts.spaceGrotesk(fontSize: 14,
              fontWeight: FontWeight.w600, color: AppTheme.textPrimaryOf(context))),
          Text(
              themeProvider.mode == ThemeMode.system
                  ? 'Follow system'
                  : themeProvider.mode == ThemeMode.dark
                  ? 'Dark mode'
                  : 'Light mode',
              // isDark ? 'Dark mode' : 'Light mode',
              style: GoogleFonts.dmSans(fontSize: 12,
                  color: AppTheme.textSecondaryOf(context))),
        ])),
        // Container(
        //   padding: const EdgeInsets.all(3),
        //   decoration: BoxDecoration(
        //     color: AppTheme.surfaceElevOf(context),
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Row(children: [
        //     _ModeChip(icon: Icons.dark_mode_rounded, label: 'Dark',
        //         active: isDark, onTap: () => themeProvider.setMode(ThemeMode.dark)),
        //     _ModeChip(icon: Icons.light_mode_rounded, label: 'Light',
        //         active: !isDark, onTap: () => themeProvider.setMode(ThemeMode.light)),
        //   ]),
        // ),

        InkWell(
          onTap: () => _showThemeSheet(context),
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              Text(
                themeProvider.mode == ThemeMode.system
                    ? 'System'
                    : themeProvider.mode == ThemeMode.dark
                    ? 'Dark'
                    : 'Light',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryOf(context),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        )
      ]),
    );
  }
  void _showThemeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceOf(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeOption(
              context,
              Icons.settings_suggest_rounded,
              'System',
              ThemeMode.system,
            ),
            _themeOption(
              context,
              Icons.dark_mode_rounded,
              'Dark',
              ThemeMode.dark,
            ),
            _themeOption(
              context,
              Icons.light_mode_rounded,
              'Light',
              ThemeMode.light,
            ),
          ],
        ),
      ),
    );
  }
  Widget _themeOption(
      BuildContext context,
      IconData icon,
      String label,
      ThemeMode mode,
      ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: themeProvider.mode == mode
          ? const Icon(Icons.check_rounded)
          : null,
      onTap: () {
        themeProvider.setMode(mode);
        Navigator.pop(context);
      },
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ModeChip({required this.icon, required this.label,
    required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14,
              color: active ? Colors.white : AppTheme.textSecondaryOf(context)),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppTheme.textSecondaryOf(context))),
        ]),
      ),
    );
  }
}

// ─── Shared tiles ─────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: AppTheme.accent, size: 20),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 14,
            fontWeight: FontWeight.w600, color: AppTheme.textPrimaryOf(context)))),
        Text(value, style: GoogleFonts.dmSans(fontSize: 13,
            color: AppTheme.textSecondaryOf(context))),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 14,
              fontWeight: FontWeight.w700, color: color))),
          Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.6), size: 20),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(label.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w700,
              color: AppTheme.textSecondaryOf(context), letterSpacing: 1.2)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderOf(context)),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: AppTheme.borderOf(context), height: 1),
    );
  }
}