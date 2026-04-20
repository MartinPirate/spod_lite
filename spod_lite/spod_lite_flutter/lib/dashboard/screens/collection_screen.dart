import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../../glass.dart';
import '../../main.dart' show client;
import '../record_form_dialog.dart';
import '../rules_dialog.dart';

class CollectionScreen extends StatefulWidget {
  final CollectionDef def;
  final VoidCallback onDeleted;
  final ValueChanged<CollectionDef>? onRulesChanged;

  const CollectionScreen({
    super.key,
    required this.def,
    required this.onDeleted,
    this.onRulesChanged,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late Future<_CollectionView> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant CollectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.def.id != widget.def.id) _refresh();
  }

  void _refresh() => setState(() => _future = _load());

  Future<_CollectionView> _load() async {
    final fields = await client.collections.fields(widget.def.id!);
    final rawRecords = await client.records.list(widget.def.name, 1, 200);
    final records = rawRecords
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
    return _CollectionView(fields: fields, records: records);
  }

  Future<void> _createRecord(List<CollectionField> fields) async {
    final data = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'New record',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) =>
          RecordFormDialog(collectionLabel: widget.def.label, fields: fields),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
    if (data == null) return;
    try {
      await client.records.create(widget.def.name, jsonEncode(data));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _snack('Create failed: $e');
    }
  }

  Future<void> _deleteRecord(int id) async {
    final ok = await _confirm(
      title: 'Delete record?',
      message: 'Record #$id will be permanently removed.',
      dangerLabel: 'Delete',
    );
    if (ok != true) return;
    try {
      await client.records.delete(widget.def.name, id);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      _snack('Delete failed: $e');
    }
  }

  Future<void> _openRules() async {
    final updated = await showGeneralDialog<CollectionDef>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Rules',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => RulesDialog(def: widget.def),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
    if (updated != null && widget.onRulesChanged != null) {
      widget.onRulesChanged!(updated);
    }
  }

  Future<void> _deleteCollection() async {
    final ok = await _confirm(
      title: 'Drop "${widget.def.name}"?',
      message: 'This drops the underlying table AND all records. '
          'This cannot be undone.',
      dangerLabel: 'Drop collection',
    );
    if (ok != true) return;
    try {
      await client.collections.delete(widget.def.name);
      widget.onDeleted();
    } catch (e) {
      if (!mounted) return;
      _snack('Drop failed: $e');
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String dangerLabel,
  }) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => Material(
        type: MaterialType.transparency,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: GlassPanel(
                radius: 18,
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Glass.text)),
                    const SizedBox(height: 6),
                    Text(message,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Glass.textMuted,
                            height: 1.5)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          child: LiquidButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            subtle: true,
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 140,
                          child: _DangerButton(
                            onPressed: () =>
                                Navigator.of(context).pop(true),
                            label: dangerLabel,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Glass.bgSoft,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: const TextStyle(color: Glass.text)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_CollectionView>(
      future: _future,
      builder: (context, snap) {
        return Column(
          children: [
            _Header(
              def: widget.def,
              onRefresh: _refresh,
              onDropCollection: _deleteCollection,
              onOpenRules: _openRules,
              recordCount: snap.data?.records.length,
            ),
            Expanded(
              child: _body(snap),
            ),
          ],
        );
      },
    );
  }

  Widget _body(AsyncSnapshot<_CollectionView> snap) {
    if (snap.connectionState != ConnectionState.done) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Glass.auroraA),
          ),
        ),
      );
    }
    if (snap.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: GlassPanel(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 22, color: Glass.danger),
                const SizedBox(height: 8),
                Text('${snap.error}',
                    style: const TextStyle(color: Glass.textMuted)),
                const SizedBox(height: 12),
                SizedBox(
                  width: 120,
                  child: LiquidButton(
                    subtle: true,
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final view = snap.data!;
    if (view.records.isEmpty) {
      return _EmptyRecords(
        label: widget.def.label,
        onCreate: () => _createRecord(view.fields),
      );
    }
    return _RecordsTable(
      fields: view.fields,
      records: view.records,
      onDelete: _deleteRecord,
      onCreate: () => _createRecord(view.fields),
    );
  }
}

class _CollectionView {
  final List<CollectionField> fields;
  final List<Map<String, dynamic>> records;
  _CollectionView({required this.fields, required this.records});
}

class _Header extends StatelessWidget {
  final CollectionDef def;
  final VoidCallback onRefresh;
  final VoidCallback onDropCollection;
  final VoidCallback onOpenRules;
  final int? recordCount;

  const _Header({
    required this.def,
    required this.onRefresh,
    required this.onDropCollection,
    required this.onOpenRules,
    required this.recordCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GlassPanel(
        radius: 16,
        blur: 30,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            const Icon(Icons.storage_rounded,
                size: 18, color: Glass.auroraA),
            const SizedBox(width: 10),
            Text(def.label,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Glass.text)),
            const SizedBox(width: 10),
            _NamePill(def.name),
            const SizedBox(width: 10),
            if (recordCount != null)
              Text('$recordCount records',
                  style: const TextStyle(
                      fontSize: 11.5, color: Glass.textSubtle)),
            const Spacer(),
            _RuleBadges(def: def, onTap: onOpenRules),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.shield_outlined, size: 16),
              color: Glass.textMuted,
              tooltip: 'Rules',
              onPressed: onOpenRules,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 16),
              color: Glass.textMuted,
              tooltip: 'Refresh',
              onPressed: onRefresh,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 16),
              color: Glass.textMuted,
              tooltip: 'Drop collection',
              onPressed: onDropCollection,
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleBadges extends StatelessWidget {
  final CollectionDef def;
  final VoidCallback onTap;
  const _RuleBadges({required this.def, required this.onTap});

  String _short(String mode) {
    switch (mode) {
      case 'public':
        return 'pub';
      case 'authed':
        return 'auth';
      case 'admin':
        return 'adm';
    }
    return mode;
  }

  Color _color(String mode) {
    switch (mode) {
      case 'public':
        return Glass.auroraD;
      case 'authed':
        return Glass.auroraA;
      case 'admin':
        return Glass.auroraB;
    }
    return Glass.textSubtle;
  }

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('list', def.listRule),
      ('view', def.viewRule),
      ('create', def.createRule),
      ('update', def.updateRule),
      ('delete', def.deleteRule),
    ];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Tooltip(
        message:
            'list ${def.listRule} · view ${def.viewRule} · create ${def.createRule} · update ${def.updateRule} · delete ${def.deleteRule}',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final e in entries) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _color(e.$2).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: _color(e.$2).withValues(alpha: 0.35)),
                  ),
                  child: Text(_short(e.$2),
                      style: TextStyle(
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w700,
                          color: _color(e.$2))),
                ),
                const SizedBox(width: 3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NamePill extends StatelessWidget {
  final String text;
  const _NamePill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Glass.hairline),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontFamily: 'monospace',
          color: Glass.textSubtle,
        ),
      ),
    );
  }
}

class _RecordsTable extends StatelessWidget {
  final List<CollectionField> fields;
  final List<Map<String, dynamic>> records;
  final void Function(int id) onDelete;
  final VoidCallback onCreate;

  const _RecordsTable({
    required this.fields,
    required this.records,
    required this.onDelete,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: GlassPanel(
        radius: 16,
        blur: 30,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
              decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Glass.hairline, width: 1)),
              ),
              child: Row(
                children: [
                  Text('${records.length} ${records.length == 1 ? "record" : "records"}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Glass.text)),
                  const Spacer(),
                  SizedBox(
                    width: 150,
                    height: 36,
                    child: LiquidButton(
                      onPressed: onCreate,
                      height: 36,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 14),
                          SizedBox(width: 6),
                          Text('New record'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Header
            _RowPad(child: _HeaderRow(fields: fields)),
            const Divider(height: 1, color: Glass.hairline),
            // Rows
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: records.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, color: Glass.hairline),
                itemBuilder: (_, i) => _RowPad(
                  child: _DataRow(
                    record: records[i],
                    fields: fields,
                    onDelete: () {
                      final id = records[i]['id'] as int?;
                      if (id != null) onDelete(id);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowPad extends StatelessWidget {
  final Widget child;
  const _RowPad({required this.child});
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);
}

class _HeaderRow extends StatelessWidget {
  final List<CollectionField> fields;
  const _HeaderRow({required this.fields});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          const SizedBox(width: 80, child: _HCell('id')),
          for (final f in fields)
            Expanded(child: _HCell(f.name)),
          const SizedBox(width: 140, child: _HCell('created_at')),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _HCell extends StatelessWidget {
  final String text;
  const _HCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.3,
          fontWeight: FontWeight.w600,
          color: Glass.textSubtle),
    );
  }
}

class _DataRow extends StatefulWidget {
  final Map<String, dynamic> record;
  final List<CollectionField> fields;
  final VoidCallback onDelete;

  const _DataRow({
    required this.record,
    required this.fields,
    required this.onDelete,
  });

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final id = widget.record['id'];
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        height: 44,
        color: _hover
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.transparent,
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: _IdPill(id: id?.toString() ?? '—'),
            ),
            for (final f in widget.fields)
              Expanded(
                child: Text(
                  _formatValue(widget.record[f.name], f.fieldType),
                  style: const TextStyle(fontSize: 13, color: Glass.text),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            SizedBox(
              width: 140,
              child: Text(
                _formatDate(widget.record['created_at']),
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Glass.textSubtle,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ),
            SizedBox(
              width: 40,
              child: _hover
                  ? IconButton(
                      icon: const Icon(Icons.delete_outline, size: 15),
                      color: Glass.textSubtle,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete',
                      onPressed: widget.onDelete,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(dynamic value, String type) {
    if (value == null) return '—';
    switch (type) {
      case 'bool':
        return value == true ? 'true' : 'false';
      case 'datetime':
        return _formatDate(value);
      case 'number':
        return value.toString();
      case 'json':
        return jsonEncode(value);
      default:
        return value.toString();
    }
  }
}

String _formatDate(dynamic dt) {
  if (dt == null) return '—';
  DateTime? parsed;
  if (dt is DateTime) parsed = dt;
  if (dt is String) parsed = DateTime.tryParse(dt);
  if (parsed == null) return dt.toString();
  final local = parsed.toLocal();
  final diff = DateTime.now().difference(local);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class _IdPill extends StatelessWidget {
  final String id;
  const _IdPill({required this.id});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Clipboard.setData(ClipboardData(text: id)),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Glass.hairline),
        ),
        child: Text(
          id,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: Glass.textSubtle,
          ),
        ),
      ),
    );
  }
}

class _EmptyRecords extends StatelessWidget {
  final String label;
  final VoidCallback onCreate;
  const _EmptyRecords({required this.label, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RiseIn(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: GlassPanel(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LiquidMark(size: 46),
                const SizedBox(height: 16),
                Text('No $label yet',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: Glass.text)),
                const SizedBox(height: 6),
                Text(
                  'Create your first record to start filling this collection.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Glass.textMuted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: 200,
                  child: LiquidButton(
                    onPressed: onCreate,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 14),
                        SizedBox(width: 6),
                        Text('New record'),
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

class _DangerButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  const _DangerButton({required this.onPressed, required this.label});

  @override
  State<_DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<_DangerButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 44,
          decoration: BoxDecoration(
            color: _hover
                ? Glass.danger.withValues(alpha: 0.18)
                : Glass.danger.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: Glass.danger.withValues(alpha: _hover ? 0.5 : 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(widget.label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Glass.danger)),
        ),
      ),
    );
  }
}
