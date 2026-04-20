import 'package:flutter/material.dart';
import '../../theme.dart';

enum FieldType { id, text, longText, number, bool, datetime, relation, file, email, json }

IconData _iconFor(FieldType t) {
  switch (t) {
    case FieldType.id: return Icons.vpn_key_outlined;
    case FieldType.text: return Icons.short_text;
    case FieldType.longText: return Icons.subject;
    case FieldType.number: return Icons.numbers;
    case FieldType.bool: return Icons.toggle_on_outlined;
    case FieldType.datetime: return Icons.schedule;
    case FieldType.relation: return Icons.link;
    case FieldType.file: return Icons.attach_file;
    case FieldType.email: return Icons.mail_outline;
    case FieldType.json: return Icons.data_object;
  }
}

class FieldIcon extends StatelessWidget {
  final FieldType type;
  const FieldIcon(this.type, {super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(_iconFor(type), size: 14, color: Tokens.textMuted);
  }
}
