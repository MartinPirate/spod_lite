import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme.dart';

class IdBadge extends StatefulWidget {
  final String value;
  const IdBadge(this.value, {super.key});

  @override
  State<IdBadge> createState() => _IdBadgeState();
}

class _IdBadgeState extends State<IdBadge> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => Clipboard.setData(ClipboardData(text: widget.value)),
        child: Tooltip(
          message: 'click to copy',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _hover ? Tokens.hover : Tokens.elevated,
              border: Border.all(
                color: _hover ? Tokens.border : Tokens.borderSubtle,
              ),
              borderRadius: BorderRadius.circular(Tokens.radiusSm),
            ),
            child: Text(
              widget.value,
              style: const TextStyle(
                fontFamily: Tokens.monoFamily,
                fontSize: 12,
                color: Tokens.textSecondary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
