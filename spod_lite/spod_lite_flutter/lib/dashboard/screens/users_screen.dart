import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../../glass.dart';
import '../../main.dart' show client;

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<AppUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = client.users.list(page: 1, perPage: 200);
  }

  void _refresh() => setState(() => _future = client.users.list(page: 1, perPage: 200));

  Future<void> _revokeSessions(AppUser u) async {
    try {
      await client.users.revokeSessions(u.id!);
      _snack('Revoked all sessions for ${u.email}.');
    } catch (e) {
      if (!mounted) return;
      _snack('Failed: $e');
    }
  }

  Future<void> _delete(AppUser u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Glass.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Glass.hairline),
        ),
        title: const Text('Delete user?',
            style: TextStyle(color: Glass.text)),
        content: Text(
          '${u.email} and all their sessions will be permanently removed.',
          style: const TextStyle(color: Glass.textMuted, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel',
                style: TextStyle(color: Glass.textSubtle)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                const Text('Delete', style: TextStyle(color: Glass.danger)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await client.users.delete(u.id!);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _snack('Delete failed: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Glass.surface,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: const TextStyle(color: Glass.text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: GlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 18, color: Glass.accent),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Users',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Glass.text)),
                    SizedBox(height: 2),
                    Text('End-user accounts signed up through app_user.',
                        style: TextStyle(
                            fontSize: 12, color: Glass.textMuted)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  color: Glass.textMuted,
                  onPressed: _refresh,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: GlassPanel(
              padding: EdgeInsets.zero,
              child: FutureBuilder<List<AppUser>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(
                      child: SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Glass.accent),
                        ),
                      ),
                    );
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Text('${snap.error}',
                          style: const TextStyle(color: Glass.textMuted)),
                    );
                  }
                  final users = snap.data ?? [];
                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Glass.hairline)),
                        ),
                        child: Row(
                          children: const [
                            SizedBox(width: 60, child: _H('id')),
                            Expanded(child: _H('email')),
                            SizedBox(width: 150, child: _H('joined')),
                            SizedBox(width: 90, child: _H('actions')),
                          ],
                        ),
                      ),
                      Expanded(
                        child: users.isEmpty
                            ? const Center(
                                child: Text('No users yet.',
                                    style:
                                        TextStyle(color: Glass.textMuted)))
                            : ListView.separated(
                                itemCount: users.length,
                                separatorBuilder: (_, _) => const Divider(
                                    height: 1, color: Glass.hairline),
                                itemBuilder: (_, i) => _UserRow(
                                  user: users[i],
                                  onRevoke: () => _revokeSessions(users[i]),
                                  onDelete: () => _delete(users[i]),
                                ),
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _H extends StatelessWidget {
  final String text;
  const _H(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: Glass.textSubtle));
}

class _UserRow extends StatefulWidget {
  final AppUser user;
  final VoidCallback onRevoke;
  final VoidCallback onDelete;
  const _UserRow({
    required this.user,
    required this.onRevoke,
    required this.onDelete,
  });

  @override
  State<_UserRow> createState() => _UserRowState();
}

class _UserRowState extends State<_UserRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: _hover
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Text('${widget.user.id}',
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Glass.textSubtle)),
            ),
            Expanded(
              child: Text(widget.user.email,
                  style:
                      const TextStyle(fontSize: 13, color: Glass.text)),
            ),
            SizedBox(
              width: 150,
              child: Text(
                _formatDate(widget.user.createdAt),
                style: const TextStyle(
                    fontSize: 12,
                    color: Glass.textSubtle,
                    fontFamily: 'monospace'),
              ),
            ),
            SizedBox(
              width: 90,
              child: Row(
                children: [
                  Tooltip(
                    message: 'Revoke all sessions',
                    child: IconButton(
                      icon: const Icon(Icons.logout, size: 14),
                      color: Glass.textSubtle,
                      visualDensity: VisualDensity.compact,
                      onPressed: widget.onRevoke,
                    ),
                  ),
                  if (_hover)
                    Tooltip(
                      message: 'Delete user',
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 14),
                        color: Glass.textSubtle,
                        visualDensity: VisualDensity.compact,
                        onPressed: widget.onDelete,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime? dt) {
  if (dt == null) return '—';
  final local = dt.toLocal();
  final diff = DateTime.now().difference(local);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
