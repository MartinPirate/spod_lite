import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../glass.dart';
import '../main.dart' show client;

const _ops = ['list', 'view', 'create', 'update', 'delete'];
const _modes = ['public', 'authed', 'admin'];

String _describe(String mode) {
  switch (mode) {
    case 'public':
      return 'Anyone — no auth required.';
    case 'authed':
      return 'Any signed-in user (admin or app user).';
    case 'admin':
      return 'Dashboard admins only.';
  }
  return '';
}

class RulesDialog extends StatefulWidget {
  final CollectionDef def;
  const RulesDialog({super.key, required this.def});

  @override
  State<RulesDialog> createState() => _RulesDialogState();
}

class _RulesDialogState extends State<RulesDialog> {
  late Map<String, String> _current;
  late Map<String, String> _initial;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initial = {
      'list': widget.def.listRule,
      'view': widget.def.viewRule,
      'create': widget.def.createRule,
      'update': widget.def.updateRule,
      'delete': widget.def.deleteRule,
    };
    _current = Map.of(_initial);
  }

  bool get _isDirty {
    for (final op in _ops) {
      if (_current[op] != _initial[op]) return true;
    }
    return false;
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final diff = <String, String>{};
      for (final op in _ops) {
        if (_current[op] != _initial[op]) {
          diff['${op}Rule'] = _current[op]!;
        }
      }
      final rulesJson = diff.isEmpty ? '{}' : _encodeJson(diff);
      final updated =
          await client.collections.updateRules(widget.def.name, rulesJson);
      if (!mounted) return;
      Navigator.of(context).pop<CollectionDef>(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  String _encodeJson(Map<String, String> m) {
    final parts = m.entries.map((e) => '"${e.key}":"${e.value}"').join(',');
    return '{$parts}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GlassPanel(
              radius: 22,
              blur: 50,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Glass.auroraB.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                              color:
                                  Glass.auroraB.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.shield_outlined,
                            size: 14, color: Glass.auroraB),
                      ),
                      const SizedBox(width: 12),
                      Text('Rules · ${widget.def.name}',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: Glass.text)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Glass.textSubtle,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Choose who can perform each operation on this collection.',
                    style: TextStyle(
                        color: Glass.textMuted,
                        fontSize: 13,
                        height: 1.5),
                  ),
                  const SizedBox(height: 18),
                  for (final op in _ops) ...[
                    _RuleRow(
                      op: op,
                      value: _current[op]!,
                      onChanged: (v) => setState(() => _current[op] = v),
                    ),
                    const SizedBox(height: 10),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Glass.danger.withValues(alpha: 0.1),
                        border: Border.all(
                            color: Glass.danger.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(_error!,
                          style: const TextStyle(
                              fontSize: 12.5, color: Glass.danger)),
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 100,
                        child: LiquidButton(
                          onPressed: _saving
                              ? null
                              : () => Navigator.of(context).pop(),
                          subtle: true,
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 140,
                        child: LiquidButton(
                          onPressed:
                              _saving || !_isDirty ? null : _save,
                          child: _saving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.black),
                                  ),
                                )
                              : Text(_isDirty ? 'Save rules' : 'No changes'),
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
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String op;
  final String value;
  final ValueChanged<String> onChanged;

  const _RuleRow({
    required this.op,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: Glass.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Glass.hairline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(op,
                style: const TextStyle(
                    fontSize: 12,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w700,
                    color: Glass.text)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(_describe(value),
                style: const TextStyle(
                    fontSize: 11.5, color: Glass.textMuted)),
          ),
          const SizedBox(width: 8),
          _Segment(
            value: value,
            options: _modes,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _Segment({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Glass.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final opt in options) _segButton(opt),
        ],
      ),
    );
  }

  Widget _segButton(String opt) {
    final selected = opt == value;
    return GestureDetector(
      onTap: selected ? null : () => onChanged(opt),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? Glass.auroraA.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected
                ? Glass.auroraA.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Text(
          opt,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: selected ? Glass.text : Glass.textSubtle,
          ),
        ),
      ),
    );
  }
}
