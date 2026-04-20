import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dashboard design tokens — Linear/Vercel/PocketBase-flavored slate.
///
/// Named `Glass` for backwards compatibility with existing imports, but
/// the aesthetic is deliberately *not* frosted — admin dashboards are
/// info-dense dev tools, not consumer surfaces. Solid panels, crisp
/// hairlines, no backdrop blur, no gradient glow.
class Glass {
  // Bases
  static const bg = Color(0xFF0B0F14);
  static const bgSoft = Color(0xFF0F141B);

  // Surfaces (all opaque)
  static const surface = Color(0xFF11161C);
  static const surfaceHover = Color(0xFF151C24);
  static const surfaceStrong = Color(0xFF1A2029);

  // Borders
  static const hairline = Color(0xFF232C38);
  static const hairlineStrong = Color(0xFF2A3441);

  // Text
  static const text = Color(0xFFE8EEF5);
  static const textMuted = Color(0xFF8B95A5);
  static const textSubtle = Color(0xFF5A6475);
  static const textFaint = Color(0xFF3F4958);

  // Accent — single sky/cyan, used sparingly.
  static const accent = Color(0xFF38BDF8);
  static const accentBright = Color(0xFF7DD3FC);
  static const accentDeep = Color(0xFF0EA5E9);

  // Secondary accents used only for the LiquidMark gradient and
  // per-op rule badges; not applied as widget fills.
  static const auroraA = Color(0xFF7DD3FC); // sky-300
  static const auroraB = Color(0xFFC084FC); // purple-400
  static const auroraC = Color(0xFFF472B6); // pink-400
  static const auroraD = Color(0xFF34D399); // emerald-400

  // States
  static const danger = Color(0xFFF87171);
  static const success = Color(0xFF34D399);
}

ThemeData buildDashboardTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
    bodyColor: Glass.text,
    displayColor: Glass.text,
  );

  return base.copyWith(
    scaffoldBackgroundColor: Glass.bg,
    canvasColor: Glass.bg,
    colorScheme: const ColorScheme.dark(
      surface: Glass.surface,
      onSurface: Glass.text,
      primary: Glass.accent,
      onPrimary: Colors.black,
      secondary: Glass.accent,
      onSecondary: Colors.black,
      error: Glass.danger,
      onError: Colors.black,
      outline: Glass.hairline,
    ),
    textTheme: textTheme.copyWith(
      headlineSmall: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4),
      titleLarge: GoogleFonts.inter(
          fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: -0.2),
      titleMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(fontSize: 14, color: Glass.text),
      bodyMedium: GoogleFonts.inter(fontSize: 13, color: Glass.text),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: Glass.textMuted),
      labelSmall: GoogleFonts.inter(
          fontSize: 11, color: Glass.textSubtle, letterSpacing: 0.3),
    ),
    iconTheme: const IconThemeData(color: Glass.textMuted, size: 18),
    dividerColor: Glass.hairline,
    splashFactory: NoSplash.splashFactory,
  );
}

/// Plain dark background — no animated blobs, no gradient.
/// Kept as a widget so consumers can swap variants later if needed.
class AuroraBackground extends StatelessWidget {
  final Widget child;
  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Glass.bg, child: child);
  }
}

/// Solid surface panel with a thin border — the dashboard's workhorse
/// container. Replaces the old frosted-glass implementation.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Color? background;

  /// Retained for API compatibility with the old frosted panel.
  /// Has no effect on this solid variant.
  // ignore: unused_element_parameter
  final double blur;

  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 10,
    this.padding = const EdgeInsets.all(16),
    this.background,
    this.blur = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background ?? Glass.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Glass.hairline),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Entrance animation — fade + subtle slide up. Works fine without glass.
class RiseIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const RiseIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 320),
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
      begin: const Offset(0, 0.04),
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

/// Clean accent button — solid sky fill, hairline on hover, no glow.
/// Kept named `LiquidButton` for API compatibility.
class LiquidButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;

  /// When true, renders a quieter secondary style.
  final bool subtle;

  const LiquidButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 36,
    this.subtle = false,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    final Color bg;
    final Color fg;
    final Color border;
    if (widget.subtle) {
      bg = _hover && enabled ? Glass.surfaceHover : Glass.surface;
      fg = Glass.text;
      border = _hover && enabled ? Glass.hairlineStrong : Glass.hairline;
    } else {
      bg = enabled
          ? (_hover ? Glass.accentBright : Glass.accent)
          : Glass.surfaceHover;
      fg = enabled ? Colors.black : Glass.textFaint;
      border = Colors.transparent;
    }

    return MouseRegion(
      cursor:
          enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: widget.height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border),
          ),
          child: Center(
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
              child: IconTheme(
                data: IconThemeData(color: fg, size: 14),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Plain text field on a solid surface — hairline border, accent focus ring.
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
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
                color: Glass.textSubtle)),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            color: Glass.bgSoft,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hasFocus ? Glass.accent : Glass.hairline,
              width: _hasFocus ? 1.2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                Icon(widget.leading, size: 14, color: Glass.textSubtle),
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
                      fontSize: 14,
                      color: Glass.text,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                        color: Glass.textFaint,
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
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

/// Brand mark — small gradient rounded square. Kept from the Liquid Glass
/// era because it reads well on any background and the gradient is on-brand.
class LiquidMark extends StatelessWidget {
  final double size;
  const LiquidMark({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          colors: [Glass.auroraA, Glass.auroraB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.bolt, color: Colors.white, size: size * 0.55),
    );
  }
}
