import 'package:flutter/material.dart';
import '../../theme.dart';
import '../widgets/empty_state.dart';

class PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PlaceholderScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: Tokens.topbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Tokens.border)),
          ),
          alignment: Alignment.centerLeft,
          child: Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Tokens.textPrimary)),
        ),
        Expanded(
          child: EmptyState(
            icon: icon,
            title: '$title — coming soon',
            subtitle: subtitle,
          ),
        ),
      ],
    );
  }
}
