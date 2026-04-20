import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../glass.dart';

class RecordFormDialog extends StatefulWidget {
  final String collectionLabel;
  final List<CollectionField> fields;

  const RecordFormDialog({
    super.key,
    required this.collectionLabel,
    required this.fields,
  });

  @override
  State<RecordFormDialog> createState() => _RecordFormDialogState();
}

class _RecordFormDialogState extends State<RecordFormDialog> {
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, bool> _boolValues = {};
  final Map<String, DateTime?> _dateValues = {};
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final f in widget.fields) {
      switch (f.fieldType) {
        case 'bool':
          _boolValues[f.name] = false;
          break;
        case 'datetime':
          _dateValues[f.name] = null;
          break;
        default:
          _textControllers[f.name] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, dynamic>? _collect() {
    final data = <String, dynamic>{};
    for (final f in widget.fields) {
      dynamic value;
      switch (f.fieldType) {
        case 'bool':
          value = _boolValues[f.name] ?? false;
          break;
        case 'datetime':
          value = _dateValues[f.name]?.toIso8601String();
          break;
        case 'number':
          final text = _textControllers[f.name]!.text.trim();
          if (text.isEmpty) {
            value = null;
          } else {
            final n = double.tryParse(text);
            if (n == null) {
              setState(() => _error = '"${f.name}" must be a number.');
              return null;
            }
            value = n;
          }
          break;
        default:
          final text = _textControllers[f.name]!.text;
          value = text.isEmpty ? null : text;
      }
      if (value == null && f.required) {
        setState(() => _error = '"${f.name}" is required.');
        return null;
      }
      if (value != null) data[f.name] = value;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
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
                      const LiquidMark(size: 30),
                      const SizedBox(width: 12),
                      Text('New ${widget.collectionLabel}',
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
                  const SizedBox(height: 18),
                  for (final f in widget.fields) ...[
                    _buildField(f),
                    const SizedBox(height: 14),
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
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 110,
                        child: LiquidButton(
                          onPressed: () => Navigator.of(context).pop(),
                          subtle: true,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 130,
                        child: LiquidButton(
                          onPressed: () {
                            final data = _collect();
                            if (data != null) {
                              Navigator.of(context).pop(data);
                            }
                          },
                          child: const Text('Create'),
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

  Widget _buildField(CollectionField f) {
    switch (f.fieldType) {
      case 'bool':
        return _BoolField(
          label: f.name,
          value: _boolValues[f.name] ?? false,
          onChanged: (v) => setState(() => _boolValues[f.name] = v),
        );
      case 'datetime':
        return _DateField(
          label: f.name,
          value: _dateValues[f.name],
          required: f.required,
          onChanged: (d) => setState(() => _dateValues[f.name] = d),
        );
      case 'longtext':
        return GlassField(
          controller: _textControllers[f.name]!,
          label: f.name.toUpperCase() + (f.required ? ' *' : ''),
          hint: 'Long text',
        );
      case 'number':
        return GlassField(
          controller: _textControllers[f.name]!,
          label: f.name.toUpperCase() + (f.required ? ' *' : ''),
          hint: '0',
          leading: Icons.numbers,
        );
      case 'json':
        return GlassField(
          controller: _textControllers[f.name]!,
          label: f.name.toUpperCase() + (f.required ? ' *' : ''),
          hint: '{ "key": "value" }',
          leading: Icons.data_object,
        );
      default:
        return GlassField(
          controller: _textControllers[f.name]!,
          label: f.name.toUpperCase() + (f.required ? ' *' : ''),
          hint: f.name,
        );
    }
  }
}

class _BoolField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _BoolField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                color: Glass.textSubtle)),
        const Spacer(),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.black,
          activeTrackColor: Glass.auroraA,
          inactiveThumbColor: Glass.textSubtle,
          inactiveTrackColor: Glass.surface,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final bool required;
  final ValueChanged<DateTime?> onChanged;
  const _DateField({
    required this.label,
    required this.value,
    required this.required,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${label.toUpperCase()}${required ? " *" : ""}',
            style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
                color: Glass.textSubtle)),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: DateTime(now.year - 10),
              lastDate: DateTime(now.year + 10),
            );
            onChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Glass.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Glass.hairline),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule,
                    size: 15, color: Glass.textSubtle),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value != null
                        ? '${value!.year}-${value!.month.toString().padLeft(2, "0")}-${value!.day.toString().padLeft(2, "0")}'
                        : 'Pick a date',
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null ? Glass.text : Glass.textFaint,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
