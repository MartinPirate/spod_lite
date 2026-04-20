import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Apple-flavored Liquid Glass design tokens.
class Glass {
  // Deep near-black with a warm undertone.
  static const bg = Color(0xFF06060A);
  static const bgSoft = Color(0xFF0A0A10);

  // Surface — used as a *base* tint under backdrop blur.
  static const surface = Color(0x1AFFFFFF); // white 10%
  static const surfaceStrong = Color(0x33FFFFFF); // white 20%
  static const surfaceHover = Color(0x26FFFFFF); // white 15%

  // Hairline borders with a subtle inner gradient feel.
  static const hairline = Color(0x29FFFFFF); // white 16%
  static const hairlineStrong = Color(0x4DFFFFFF); // white 30%

  static const text = Color(0xFFF2F3F7);
  static const textMuted = Color(0xB3FFFFFF); // white 70%
  static const textSubtle = Color(0x80FFFFFF); // white 50%
  static const textFaint = Color(0x4DFFFFFF); // white 30%

  // Aurora accent palette — pulls through the glass.
  static const auroraA = Color(0xFF7DD3FC); // sky-300
  static const auroraB = Color(0xFFC084FC); // purple-400
  static const auroraC = Color(0xFFF472B6); // pink-400
  static const auroraD = Color(0xFF34D399); // emerald-400

  static const accent = Color(0xFF7DD3FC);
  static const accentDeep = Color(0xFF0EA5E9);
  static const danger = Color(0xFFFB7185);
}

ThemeData buildDemoTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: Glass.text,
    displayColor: Glass.text,
  );

  return base.copyWith(
    scaffoldBackgroundColor: Glass.bg,
    canvasColor: Glass.bg,
    colorScheme: const ColorScheme.dark(
      surface: Glass.bgSoft,
      onSurface: Glass.text,
      primary: Glass.accent,
      onPrimary: Colors.black,
      secondary: Glass.accent,
      onSecondary: Colors.black,
      error: Glass.danger,
      onError: Colors.black,
    ),
    textTheme: textTheme.copyWith(
      displayLarge: GoogleFonts.inter(
          fontSize: 56, fontWeight: FontWeight.w700, letterSpacing: -2.5),
      displayMedium: GoogleFonts.inter(
          fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1.8),
      headlineLarge: GoogleFonts.inter(
          fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1.2),
      headlineMedium: GoogleFonts.inter(
          fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.9),
      headlineSmall: GoogleFonts.inter(
          fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.6),
      titleLarge: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.3),
      titleMedium: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      bodyLarge: GoogleFonts.inter(
          fontSize: 15, color: Glass.text, height: 1.55),
      bodyMedium: GoogleFonts.inter(
          fontSize: 13.5, color: Glass.textMuted, height: 1.55),
      bodySmall: GoogleFonts.inter(
          fontSize: 12, color: Glass.textSubtle, height: 1.5),
      labelSmall: GoogleFonts.inter(
          fontSize: 11, color: Glass.textFaint, letterSpacing: 0.4),
    ),
    iconTheme: const IconThemeData(color: Glass.textMuted, size: 20),
    dividerColor: Glass.hairline,
    splashFactory: NoSplash.splashFactory,
  );
}

/// Animated aurora background — slowly-drifting blurred color blobs over
/// near-black. Produces the "light leaking through" feel that frosted glass
/// surfaces sit on top of.
class AuroraBackground extends StatefulWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Stack(
          children: [
            Positioned.fill(child: Container(color: Glass.bg)),
            _blob(
              left: 0.1 + 0.1 * _wave(t, 0.0),
              top: 0.05 + 0.08 * _wave(t, 0.25),
              size: 620,
              color: Glass.auroraB,
              opacity: 0.30,
            ),
            _blob(
              left: 0.55 + 0.12 * _wave(t, 0.5),
              top: 0.2 + 0.06 * _wave(t, 0.75),
              size: 520,
              color: Glass.auroraA,
              opacity: 0.28,
            ),
            _blob(
              left: 0.35 + 0.08 * _wave(t, 0.33),
              top: 0.55 + 0.10 * _wave(t, 0.66),
              size: 600,
              color: Glass.auroraC,
              opacity: 0.22,
            ),
            _blob(
              left: 0.7 + 0.08 * _wave(t, 0.7),
              top: 0.6 + 0.10 * _wave(t, 0.15),
              size: 460,
              color: Glass.auroraD,
              opacity: 0.18,
            ),
            // Scrim to unify and calm
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Glass.bg.withValues(alpha: 0.55),
                      Glass.bg.withValues(alpha: 0.25),
                      Glass.bg.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }

  Widget _blob({
    required double left,
    required double top,
    required double size,
    required Color color,
    required double opacity,
  }) {
    return LayoutBuilder(builder: (_, c) {
      return Positioned(
        left: c.maxWidth * left - size / 2,
        top: c.maxHeight * top - size / 2,
        width: size,
        height: size,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: opacity),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  double _wave(double t, double phase) {
    final p = (t + phase) * 6.28318;
    // two sines layered so it never repeats in a boring way
    return 0.5 * (0.6 * _sin(p) + 0.4 * _sin(p * 1.7));
  }

  double _sin(double x) {
    // tiny replacement to avoid dart:math import here
    const pi2 = 6.28318;
    final a = ((x % pi2) + pi2) % pi2 - 3.14159;
    // Bhaskara I approx — good enough for ambient motion
    final num = 16 * a * (3.14159 - a.abs());
    final den = 49.348 - 4 * a * (3.14159 - a.abs());
    return num / den;
  }
}

/// Frosted glass panel — true backdrop blur with a subtle hairline and
/// top highlight, matching iOS 26 Liquid Glass surfaces.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final Color? tint;

  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding = const EdgeInsets.all(24),
    this.blur = 40,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (tint ?? Colors.white).withValues(alpha: 0.14),
                (tint ?? Colors.white).withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(color: Glass.hairline, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Inner top highlight — the "glass shine"
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.0),
                        Colors.white.withValues(alpha: 0.35),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Entrance animation — fades and spring-slides up. Wrap any widget with
/// this for the "landing softly" iOS feel.
class RiseIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const RiseIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 720),
  });

  @override
  State<RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<RiseIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Liquid pill button — gradient fill, subtle glass sheen, spring hover.
class LiquidButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final bool subtle;

  const LiquidButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 50,
    this.subtle = false,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> {
  bool _hover = false;
  bool _press = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final scale = _press ? 0.98 : (_hover && enabled ? 1.01 : 1.0);

    final gradient = widget.subtle
        ? LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.12),
              Colors.white.withValues(alpha: 0.06),
            ],
          )
        : const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFE5F3FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          );

    return MouseRegion(
      cursor:
          enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _press = true),
        onTapUp: (_) => setState(() => _press = false),
        onTapCancel: () => setState(() => _press = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(widget.height / 2),
              border: Border.all(
                color: widget.subtle
                    ? Glass.hairlineStrong
                    : Colors.white.withValues(alpha: 0.9),
              ),
              boxShadow: enabled && !widget.subtle
                  ? [
                      BoxShadow(
                        color: Colors.white
                            .withValues(alpha: _hover ? 0.35 : 0.2),
                        blurRadius: _hover ? 30 : 18,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Glass.accent.withValues(alpha: 0.25),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: widget.subtle ? Glass.text : Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                child: IconTheme(
                  data: IconThemeData(
                    color: widget.subtle ? Glass.text : Colors.black,
                    size: 16,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass-styled text input — translucent fill, thin hairline, soft focus.
class GlassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final IconData? leading;

  const GlassField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.autofocus = false,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
    this.leading,
  });

  @override
  State<GlassField> createState() => _GlassFieldState();
}

class _GlassFieldState extends State<GlassField> {
  final _focus = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _hasFocus = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                color: Glass.textSubtle)),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _hasFocus ? Glass.surfaceStrong : Glass.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hasFocus ? Glass.hairlineStrong : Glass.hairline,
              width: 1,
            ),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: Glass.accent.withValues(alpha: 0.25),
                      blurRadius: 24,
                    )
                  ]
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                Icon(widget.leading, size: 15, color: Glass.textSubtle),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: widget.obscureText,
                  autofocus: widget.autofocus,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: Glass.accent,
                  style: const TextStyle(
                      fontSize: 15,
                      color: Glass.text,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                        color: Glass.textFaint,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (widget.suffix != null) widget.suffix!,
            ],
          ),
        ),
      ],
    );
  }
}

/// Brand mark — liquid gradient with ambient glow.
class LiquidMark extends StatelessWidget {
  final double size;
  const LiquidMark({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: const LinearGradient(
          colors: [
            Glass.auroraA,
            Glass.auroraB,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Glass.auroraA.withValues(alpha: 0.55),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Glass.auroraB.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Icon(Icons.bolt, color: Colors.white, size: size * 0.55),
          ),
          Positioned(
            top: 1, left: 1, right: 1,
            child: Container(
              height: size * 0.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.28),
                  topRight: Radius.circular(size * 0.28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.0),
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
