import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../auth/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer2<AuthProvider, ThemeProvider>(
          builder: (_, auth, themeProvider, __) {
            final isDark = themeProvider.isDark;
            final textPrimary =
            isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight;
            final textSecondary =
            isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight;
            final surfaceColor =
            isDark ? AppTheme.surface : AppTheme.surfaceLight;
            final borderColor =
            isDark ? AppTheme.border : AppTheme.borderLight;

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Text(
                      'Settings',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ),

                // Account card
                SliverToBoxAdapter(
                  child: _AccountCard(
                    auth: auth,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                ),

                // Appearance section
                SliverToBoxAdapter(
                  child: _SectionLabel(
                      label: 'Appearance',
                      textSecondary: textSecondary),
                ),
                SliverToBoxAdapter(
                  child: _SettingsCard(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    children: [
                      _ThemeToggleTile(
                        themeProvider: themeProvider,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),
                ),

                // About section
                SliverToBoxAdapter(
                  child: _SectionLabel(
                      label: 'About', textSecondary: textSecondary),
                ),
                SliverToBoxAdapter(
                  child: _SettingsCard(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    children: [
                      _InfoTile(
                        icon: Icons.info_outline_rounded,
                        label: 'App Version',
                        value: '1.0.0',
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      _DividerLine(color: borderColor),
                      _InfoTile(
                        icon: Icons.edit_note_rounded,
                        label: 'DraftIt',
                        value: 'From Classroom to Career',
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                      _DividerLine(color: borderColor),
                      _InfoTile(
                        icon: Icons.rocket_launch_outlined,
                        label: 'Powered by',
                        value: 'Groq AI · Firebase · Flutter',
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      ),
                    ],
                  ),
                ),

                // Danger zone
                SliverToBoxAdapter(
                  child: _SectionLabel(
                      label: 'Account', textSecondary: textSecondary),
                ),
                SliverToBoxAdapter(
                  child: _SettingsCard(
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    children: [
                      _ActionTile(
                        icon: Icons.logout_rounded,
                        label: 'Sign Out',
                        color: AppTheme.error,
                        onTap: () => _confirmSignOut(context, auth),
                        textPrimary: AppTheme.error,
                      ),
                    ],
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    final isDark = context.read<ThemeProvider>().isDark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surface : AppTheme.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppTheme.error, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Sign Out?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ll need to sign in again to access your notes, exam questions, and career profile.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: isDark ? AppTheme.border : AppTheme.borderLight),
                    foregroundColor: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondaryLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Cancel',
                      style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await auth.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: Text('Yes, Sign Out',
                      style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Account Card ─────────────────────────────────────────────────────────────
class _AccountCard extends StatelessWidget {
  final AuthProvider auth;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _AccountCard({
    required this.auth,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final isGoogle = auth.user?.providerData
        .any((p) => p.providerId == 'google.com') ??
        false;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accent.withOpacity(0.12),
            const Color(0xFF9D40FF).withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFF9D40FF)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                auth.initials,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.displayName.isNotEmpty
                      ? auth.displayName
                      : 'DraftIt User',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  auth.user?.email ?? '',
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: textSecondary),
                ),
                const SizedBox(height: 6),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isGoogle
                          ? const Color(0xFF4285F4).withOpacity(0.12)
                          : AppTheme.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(
                        isGoogle
                            ? Icons.g_mobiledata_rounded
                            : Icons.email_outlined,
                        size: 13,
                        color: isGoogle
                            ? const Color(0xFF4285F4)
                            : AppTheme.accentLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isGoogle ? 'Google Account' : 'Email Account',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isGoogle
                              ? const Color(0xFF4285F4)
                              : AppTheme.accentLight,
                        ),
                      ),
                    ]),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Theme Toggle Tile ────────────────────────────────────────────────────────
class _ThemeToggleTile extends StatelessWidget {
  final ThemeProvider themeProvider;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _ThemeToggleTile({
    required this.themeProvider,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.amber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: AppTheme.amber,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textPrimary)),
              Text(isDark ? 'Dark mode' : 'Light mode',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: textSecondary)),
            ],
          ),
        ),
        // Mode picker
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceElevated : AppTheme.surfaceElevLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            _ModeChip(
              icon: Icons.dark_mode_rounded,
              label: 'Dark',
              active: isDark,
              onTap: () => themeProvider.setMode(ThemeMode.dark),
            ),
            _ModeChip(
              icon: Icons.light_mode_rounded,
              label: 'Light',
              active: !isDark,
              onTap: () => themeProvider.setMode(ThemeMode.light),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModeChip(
      {required this.icon,
        required this.label,
        required this.active,
        required this.onTap});

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
          Icon(icon,
              size: 14,
              color: active ? Colors.white : AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                  active ? Colors.white : AppTheme.textSecondary)),
        ]),
      ),
    );
  }
}

// ─── Shared Tiles ─────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Icon(icon, color: AppTheme.accent, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary)),
        ),
        Text(value,
            style: GoogleFonts.dmSans(fontSize: 13, color: textSecondary)),
      ]),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textPrimary;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.textPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Text(label,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textPrimary)),
          const Spacer(),
          Icon(Icons.chevron_right_rounded,
              color: color.withOpacity(0.6), size: 20),
        ]),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textSecondary;
  const _SectionLabel({required this.label, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;

  const _SettingsCard({
    required this.children,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }
}

class _DividerLine extends StatelessWidget {
  final Color color;
  const _DividerLine({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: color, height: 1),
    );
  }
}