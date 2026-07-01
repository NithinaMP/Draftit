import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/onboarding_service.dart';
import '../theme/app_theme.dart';

enum TooltipDirection { above, below }

class OnboardingTooltip extends StatefulWidget {
  final String tooltipKey;
  final String message;
  final Widget child;
  final TooltipDirection direction;

  const OnboardingTooltip({
    super.key,
    required this.tooltipKey,
    required this.message,
    required this.child,
    this.direction = TooltipDirection.below,
  });

  @override
  State<OnboardingTooltip> createState() => _OnboardingTooltipState();
}

class _OnboardingTooltipState extends State<OnboardingTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _slide;
  bool _entranceStarted = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<double>(begin: 10.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    OnboardingService.instance.addListener(_onServiceChanged);
    _maybeStartEntrance();
  }

  void _onServiceChanged() {
    if (!mounted) return;
    final seen = OnboardingService.instance.hasSeenTooltip(widget.tooltipKey);
    if (seen) {
      if (_ctrl.value > 0) _ctrl.reverse();
    } else {
      _maybeStartEntrance();
    }
  }

  Future<void> _maybeStartEntrance() async {
    if (_entranceStarted) return;
    if (!OnboardingService.instance.isLoaded) return;
    if (OnboardingService.instance.hasSeenTooltip(widget.tooltipKey)) return;
    _entranceStarted = true;
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    if (OnboardingService.instance.hasSeenTooltip(widget.tooltipKey)) return;
    _ctrl.forward();
  }

  // SINGLE source of dismissal. No competing gesture detectors anywhere.
  void _dismiss() {
    OnboardingService.instance.markTooltipSeen(widget.tooltipKey);
  }

  @override
  void dispose() {
    OnboardingService.instance.removeListener(_onServiceChanged);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBelow = widget.direction == TooltipDirection.below;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: widget.tooltipKey == OnboardingService.tooltipDashboard
          ? screenWidth - 48
          : null,
      height: widget.tooltipKey == OnboardingService.tooltipDashboard
          ? 180
          : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.tooltipKey == OnboardingService.tooltipDashboard
              ? Align(
            alignment: Alignment.bottomRight,
            child: widget.child,
          )
              : widget.child,

          // if (widget.tooltipKey == OnboardingService.tooltipDashboard)
          //   Align(
          //     alignment: Alignment.bottomRight,
          //     child: widget.child,
          //   )
          // else
          //
          // widget.child,
          AnimatedBuilder(
            animation: _ctrl,
            builder: (ctx, child) {
              if (_ctrl.value == 0.0) return const SizedBox.shrink();
              return Positioned(
                top: isBelow ? 56 : null,
                bottom: isBelow ? null : 56,
                right: 0,
                width: (screenWidth - 48).clamp(200.0, 420.0),
                // IgnorePointer wraps everything EXCEPT during full visibility,
                // preventing any stray hit-test interference from animation layers
                child: IgnorePointer(
                  ignoring: _ctrl.value < 0.1, // only block taps while invisible/fading
                  child: Opacity(
                    opacity: _fade.value,
                    child: Transform.translate(
                      offset:
                      Offset(0, isBelow ? _slide.value : -_slide.value),
                      child: child,
                    ),
                  ),
                ),
              );
            },
            // FIX: Single tap handler via raw Listener — bypasses gesture
            // arena competition entirely. No nested GestureDetector/InkWell
            // fighting for the same pointer event.
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerUp: (_) => _dismiss(),
              child: _TooltipBubble(
                message: widget.message,
                direction: widget.direction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bubble — purely visual now, NO gesture handling inside it ────────────────
class _TooltipBubble extends StatelessWidget {
  final String message;
  final TooltipDirection direction;

  const _TooltipBubble({
    required this.message,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final isBelow = direction == TooltipDirection.below;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isBelow)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: CustomPaint(
              size: const Size(14, 7),
              painter: _ArrowPainter(pointUp: true),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.accent, Color(0xFF9D40FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white70, size: 15),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: Colors.white, height: 1.4),
                ),
              ),
              const SizedBox(width: 8),
              // Purely visual icon now — the WHOLE bubble dismisses via
              // the Listener wrapping it, so this icon doesn't need its
              // own tap handler at all.
              const Icon(Icons.close_rounded,
                  color: Colors.white70, size: 16),
            ],
          ),
        ),
        if (!isBelow)
          Padding(
            padding: const EdgeInsets.only(left: 300),
            child: CustomPaint(
              size: const Size(14, 7),
              painter: _ArrowPainter(pointUp: false),
            ),
          ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final bool pointUp;
  const _ArrowPainter({required this.pointUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppTheme.accent, Color(0xFF9D40FF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    final path = Path();
    if (pointUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}