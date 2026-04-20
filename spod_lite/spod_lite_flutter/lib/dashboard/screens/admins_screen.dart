import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../../glass.dart';
import '../../main.dart' show client;

class AdminsScreen extends StatefulWidget {
  const AdminsScreen({super.key});

  @override
  State<AdminsScreen> createState() => _AdminsScreenState();
}

class _AdminsScreenState extends State<AdminsScreen> {
  late Future<List<AdminUser>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<AdminUser>> _load() => client.admins.list();
  void _refresh() => setState(() => _future = _load());

  Future<void> _invite() async {
    final result = await showDialog<({String email, String password})>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => const _NewAdminDialog(),
    );
    if (result == null) return;
    try {
      await client.admins.invite(result.email, result.password);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _snack('Invite failed: ${_message(e)}');
    }
  }

  Future<void> _revoke(AdminUser a) async {
    final ok = await _confirmRevoke(a.email);
    if (ok != true) return;
    try {
      await client.admins.revoke(a.id!);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _snack('Revoke failed: ${_message(e)}');
    }
  }

  Future<bool?> _confirmRevoke(String email) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Glass.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Glass.hairline),
          ),
          title: const Text('Revoke admin?',
              style: TextStyle(color: Glass.text)),
          content: Text(
            '$email will be removed and their sessions invalidated.',
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
              child: const Text('Revoke',
                  style: TextStyle(color: Glass.danger)),
            ),
          ],
        ),
      );

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Glass.surface,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: const TextStyle(color: Glass.text)),
      ),
    );
  }

  String _message(Object e) {
    try {
      final m = (e as dynamic).message;
      if (m is String && m.isNotEmpty) return m;
    } catch (_) {}
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          icon: Icons.shield_moon_outlined,
          title: 'Admins',
          subtitle: 'Dashboard operators. At least one admin must always exist.',
          actionLabel: 'New admin',
          onAction: _invite,
          onRefresh: _refresh,
        ),
        Expanded(
          child: FutureBuilder<List<AdminUser>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
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
              final admins = snap.data ?? [];
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: GlassPanel(
                  padding: EdgeInsets.zero,
                  child: _AdminsTable(admins: admins, onRevoke: _revoke),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminsTable extends StatelessWidget {
  final List<AdminUser> admins;
  final void Function(AdminUser) onRevoke;
  const _AdminsTable({required this.admins, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Glass.hairline)),
          ),
          child: Row(
            children: const [
              SizedBox(width: 60, child: _HCell('id')),
              Expanded(child: _HCell('email')),
              SizedBox(width: 170, child: _HCell('created')),
              SizedBox(width: 40),
            ],
          ),
        ),
        Expanded(
          child: admins.isEmpty
              ? const Center(
                  child: Text('No admins.',
                      style: TextStyle(color: Glass.textMuted)),
                )
              : ListView.separated(
                  itemCount: admins.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: Glass.hairline),
                  itemBuilder: (_, i) {
                    final a = admins[i];
                    return _AdminRow(admin: a, onRevoke: () => onRevoke(a));
                  },
                ),
        ),
      ],
    );
  }
}

class _AdminRow extends StatefulWidget {
  final AdminUser admin;
  final VoidCallback onRevoke;
  const _AdminRow({required this.admin, required this.onRevoke});

  @override
  State<_AdminRow> createState() => _AdminRowState();
}

class _AdminRowState extends State<_AdminRow> {
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
              child: Text(
                '${widget.admin.id}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Glass.textSubtle,
                ),
              ),
            ),
            Expanded(
              child: Text(widget.admin.email,
                  style: const TextStyle(fontSize: 13, color: Glass.text)),
            ),
            SizedBox(
              width: 170,
              child: Text(
                _formatDate(widget.admin.createdAt),
                style: const TextStyle(
                    fontSize: 12, color: Glass.textSubtle,
                    fontFamily: 'monospace'),
              ),
            ),
            SizedBox(
              width: 40,
              child: _hover
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, size: 15),
                      color: Glass.textSubtle,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Revoke',
                      onPressed: widget.onRevoke,
                    )
                  : null,
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onRefresh;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Glass.accent),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Glass.text)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Glass.textMuted)),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.refresh, size: 16),
              color: Glass.textMuted,
              onPressed: onRefresh,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 4),
              SizedBox(
                width: 140,
                height: 34,
                child: LiquidButton(
                  onPressed: onAction,
                  height: 34,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 13),
                      const SizedBox(width: 5),
                      Text(actionLabel!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HCell extends StatelessWidget {
  final String text;
  const _HCell(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: Glass.textSubtle));
}

class _NewAdminDialog extends StatefulWidget {
  const _NewAdminDialog();
  @override
  State<_NewAdminDialog> createState() => _NewAdminDialogState();
}

class _NewAdminDialogState extends State<_NewAdminDialog> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlassPanel(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_moon_outlined,
                      size: 18, color: Glass.accent),
                  const SizedBox(width: 10),
                  const Text('New admin',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Glass.text)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: Glass.textSubtle,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GlassField(
                controller: _email,
                label: 'EMAIL',
                leading: Icons.alternate_email,
                hint: 'admin@example.com',
              ),
              const SizedBox(height: 12),
              GlassField(
                controller: _password,
                label: 'PASSWORD',
                leading: Icons.lock_outline,
                obscureText: true,
                hint: 'at least 8 characters',
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    child: LiquidButton(
                      subtle: true,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: LiquidButton(
                      onPressed: () => Navigator.of(context).pop((
                        email: _email.text.trim(),
                        password: _password.text,
                      )),
                      child: const Text('Create admin'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
