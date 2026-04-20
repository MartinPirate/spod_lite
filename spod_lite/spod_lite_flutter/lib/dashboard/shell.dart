import 'package:flutter/material.dart';
import '../auth/auth_state.dart';
import '../theme.dart';
import 'nav_rail.dart';
import 'screens/posts_screen.dart';
import 'screens/placeholder_screen.dart';

class DashboardShell extends StatefulWidget {
  final AuthState auth;
  const DashboardShell({super.key, required this.auth});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  NavSection _section = NavSection.collections;
  String _collection = 'posts';

  static const _collections = [
    CollectionEntry('posts', icon: Icons.description_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tokens.bg,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NavRail(
            section: _section,
            onSectionChanged: (s) => setState(() => _section = s),
            selectedCollection: _collection,
            collections: _collections,
            onSelectCollection: (c) => setState(() => _collection = c),
            onNewCollection: _showSoon,
            adminEmail: widget.auth.admin?.email,
            onSignOut: () => widget.auth.signOut(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _content() {
    switch (_section) {
      case NavSection.collections:
        return const PostsScreen();
      case NavSection.logs:
        return const PlaceholderScreen(
          icon: Icons.receipt_long_outlined,
          title: 'Logs',
          subtitle: 'Request logs and realtime tail — arriving in M2.',
        );
      case NavSection.settings:
        return const PlaceholderScreen(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'Auth providers, mail, backups — arriving in M3.',
        );
    }
  }

  void _showSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Tokens.elevated,
        content: const Text(
          'Collection builder is on the roadmap (M1).',
          style: TextStyle(color: Tokens.textPrimary, fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Tokens.radiusMd),
          side: const BorderSide(color: Tokens.border),
        ),
      ),
    );
  }
}
