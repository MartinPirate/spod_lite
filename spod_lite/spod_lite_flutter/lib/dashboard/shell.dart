import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../auth/auth_state.dart';
import '../glass.dart';
import '../main.dart' show client;
import 'nav_rail.dart';
import 'schema_editor_dialog.dart';
import 'screens/collection_screen.dart';
import 'screens/placeholder_screen.dart';

class DashboardShell extends StatefulWidget {
  final AuthState auth;
  const DashboardShell({super.key, required this.auth});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  NavSection _section = NavSection.collections;
  List<CollectionDef> _collections = [];
  bool _loading = true;
  CollectionDef? _selected;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections({CollectionDef? autoSelect}) async {
    setState(() => _loading = true);
    try {
      final list = await client.collections.list();
      setState(() {
        _collections = list;
        _loading = false;
        // Preserve selection if possible.
        if (autoSelect != null) {
          _selected = autoSelect;
        } else if (_selected != null &&
            !list.any((c) => c.name == _selected!.name)) {
          _selected = null;
        } else if (_selected == null && list.isNotEmpty) {
          _selected = list.first;
        }
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Glass.bgSoft,
          behavior: SnackBarBehavior.floating,
          content: Text('Failed to load collections: $e',
              style: const TextStyle(color: Glass.text)),
        ),
      );
    }
  }

  Future<void> _openSchemaEditor() async {
    final created = await showGeneralDialog<CollectionDef>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'New collection',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) => const SchemaEditorDialog(),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
    if (created != null) {
      await _loadCollections(autoSelect: created);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Glass.bg,
      body: AuroraBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 260,
                  child: NavRail(
                    section: _section,
                    onSectionChanged: (s) => setState(() => _section = s),
                    collections: _collections,
                    collectionsLoading: _loading,
                    selectedCollectionName: _selected?.name,
                    onSelectCollection: (c) => setState(() => _selected = c),
                    onNewCollection: _openSchemaEditor,
                    onRefreshCollections: _loadCollections,
                    adminEmail: widget.auth.admin?.email,
                    onSignOut: () => widget.auth.signOut(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: _content()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content() {
    switch (_section) {
      case NavSection.collections:
        if (_loading && _collections.isEmpty) {
          return const Center(
            child: SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Glass.auroraA),
              ),
            ),
          );
        }
        if (_selected == null) {
          return _WelcomePane(onCreate: _openSchemaEditor);
        }
        return CollectionScreen(
          key: ValueKey(_selected!.id),
          def: _selected!,
          onDeleted: () async {
            setState(() => _selected = null);
            await _loadCollections();
          },
          onRulesChanged: (updated) {
            setState(() {
              _selected = updated;
              _collections = [
                for (final c in _collections)
                  if (c.id == updated.id) updated else c
              ];
            });
          },
        );
      case NavSection.logs:
        return const PlaceholderScreen(
          icon: Icons.receipt_long_outlined,
          title: 'Logs',
          subtitle: 'Request logs and realtime tail — arriving in a later phase.',
        );
      case NavSection.settings:
        return const PlaceholderScreen(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'Auth providers, mail, backups — arriving in a later phase.',
        );
    }
  }
}

class _WelcomePane extends StatelessWidget {
  final VoidCallback onCreate;
  const _WelcomePane({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RiseIn(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: GlassPanel(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LiquidMark(size: 52),
                const SizedBox(height: 20),
                const Text('Welcome to your dashboard',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: Glass.text)),
                const SizedBox(height: 6),
                const Text(
                  'Collections are the shape of your data — create one to '
                  'get a typed table and a record browser.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Glass.textMuted, fontSize: 13.5, height: 1.55),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: 220,
                  child: LiquidButton(
                    onPressed: onCreate,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 14),
                        SizedBox(width: 6),
                        Text('Create your first collection'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
