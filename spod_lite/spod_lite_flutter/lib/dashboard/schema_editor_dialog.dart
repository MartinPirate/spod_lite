import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../glass.dart';
import '../main.dart' show client;

const _fieldTypes = ['text', 'longtext', 'number', 'bool', 'datetime', 'json'];

class SchemaEditorDialog extends StatefulWidget {
  const SchemaEditorDialog({super.key});

  @override
  State<SchemaEditorDialog> createState() => _SchemaEditorDialogState();
}

class _SchemaEditorDialogState extends State<SchemaEditorDialog> {
  final _name = TextEditingController();
  final _label = TextEditingController();
  final List<_FieldRow> _fields = [
    _FieldRow(),
  ];
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _label.dispose();
    for (final f in _fields) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final label = _label.text.trim().isEmpty ? name : _label.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Collection name is required.');
      return;
    }
    final specs = <Map<String, dynamic>>[];
    for (final f in _fields) {
      final fname = f.name.text.trim();
      if (fname.isEmpty) continue;
      specs.add({
        'name': fname,
        'fieldType': f.type,
        'required': f.required,
      });
    }
    if (specs.isEmpty) {
      setState(() => _error = 'Add at least one field.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final created = await client.collections.create(
        name,
        label,
        jsonEncode(specs),
      );
      if (!mounted) return;
      Navigator.of(context).pop<CollectionDef>(created);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _clean(e);
      });
    }
  }

  String _clean(Object e) {
    final s = e.toString();
    final m = RegExp(r'[A-Z][a-zA-Z]*Exception[^:]*:\s*(.+)').firstMatch(s);
    return (m?.group(1) ?? s).trim();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
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
                      const LiquidMark(size: 32),
                      const SizedBox(width: 12),
                      const Text('New collection',
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              color: Glass.text)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Glass.textSubtle,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GlassField(
                          controller: _name,
                          label: 'NAME',
                          hint: 'e.g. todo (lowercase, no spaces)',
                          leading: Icons.tag,
                          autofocus: true,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GlassField(
                          controller: _label,
                          label: 'LABEL',
                          hint: 'e.g. Todos',
                          leading: Icons.label_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Text('FIELDS',
                          style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 0.6,
                              fontWeight: FontWeight.w700,
                              color: Glass.textSubtle)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._fields.asMap().entries.map((entry) {
                    final i = entry.key;
                    final row = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _FieldRowWidget(
                        row: row,
                        onRemove: _fields.length > 1
                            ? () => setState(() {
                                  row.dispose();
                                  _fields.removeAt(i);
                                })
                            : null,
                        onChanged: () => setState(() {}),
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add field'),
                      style: TextButton.styleFrom(
                        foregroundColor: Glass.auroraA,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                      onPressed: () =>
                          setState(() => _fields.add(_FieldRow())),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Glass.danger.withValues(alpha: 0.1),
                        border: Border.all(
                            color: Glass.danger.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline,
                              size: 14, color: Glass.danger),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_error!,
                                style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Glass.danger,
                                    height: 1.45)),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 110,
                        child: LiquidButton(
                          onPressed: _submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          subtle: true,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 150,
                        child: LiquidButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        Colors.black),
                                  ),
                                )
                              : const Text('Create collection'),
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

class _FieldRow {
  final TextEditingController name;
  String type;
  bool required;

  _FieldRow({String initialName = '', String initialType = 'text'})
      : name = TextEditingController(text: initialName),
        type = initialType,
        required = false;

  void dispose() {
    name.dispose();
  }
}

class _FieldRowWidget extends StatelessWidget {
  final _FieldRow row;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _FieldRowWidget({
    required this.row,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: Glass.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Glass.hairline),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: row.name,
              style: const TextStyle(fontSize: 13, color: Glass.text),
              cursorColor: Glass.auroraA,
              decoration: const InputDecoration(
                hintText: 'field_name',
                hintStyle: TextStyle(color: Glass.textFaint, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: DropdownButton<String>(
              value: row.type,
              underline: const SizedBox.shrink(),
              dropdownColor: Glass.bgSoft,
              isDense: true,
              style: const TextStyle(fontSize: 13, color: Glass.text),
              icon: const Icon(Icons.expand_more,
                  size: 16, color: Glass.textSubtle),
              items: _fieldTypes
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t,
                            style: const TextStyle(color: Glass.text)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  row.type = v;
                  onChanged();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          _Toggle(
            value: row.required,
            onChanged: (v) {
              row.required = v;
              onChanged();
            },
          ),
          if (onRemove != null)
            IconButton(
              icon: const Icon(Icons.close, size: 14),
              color: Glass.textSubtle,
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
            )
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _Toggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: value
              ? Glass.auroraA.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: value ? Glass.auroraA.withValues(alpha: 0.5) : Glass.hairline,
          ),
        ),
        child: Text(
          value ? 'required' : 'optional',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 0.3,
            fontWeight: FontWeight.w600,
            color: value ? Glass.auroraA : Glass.textSubtle,
          ),
        ),
      ),
    );
  }
}
