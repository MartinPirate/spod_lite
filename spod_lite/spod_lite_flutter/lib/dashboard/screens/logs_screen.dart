import 'dart:convert';

import 'package:flutter/material.dart';

import '../../glass.dart';
import '../../main.dart' show client;

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final raw = await client.logs.recent(100);
    return raw
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  void _refresh() => setState(() => _future = _load());

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
                const Icon(Icons.receipt_long_outlined,
                    size: 18, color: Glass.accent),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Request logs',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Glass.text)),
                    SizedBox(height: 2),
                    Text('Latest 100 entries from Serverpod\'s session log.',
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
              child: FutureBuilder<List<Map<String, dynamic>>>(
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
                  final logs = snap.data ?? [];
                  if (logs.isEmpty) {
                    return const Center(
                      child: Text('No log entries.',
                          style: TextStyle(color: Glass.textMuted)),
                    );
                  }
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
                            SizedBox(width: 170, child: _H('time')),
                            SizedBox(width: 80, child: _H('method')),
                            Expanded(child: _H('endpoint')),
                            SizedBox(width: 70, child: _H('queries')),
                            SizedBox(width: 80, child: _H('duration')),
                            SizedBox(width: 20),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: logs.length,
                          separatorBuilder: (_, _) => const Divider(
                              height: 1, color: Glass.hairline),
                          itemBuilder: (_, i) => _LogRow(entry: logs[i]),
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

class _LogRow extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _LogRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final slow = entry['slow'] == true;
    final err = (entry['error']?.toString() ?? '').isNotEmpty;
    final duration = entry['duration'] as num?;
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 170,
            child: Text(
              _fmtTime(entry['time']),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontFamily: 'monospace',
                  color: Glass.textSubtle),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              entry['method']?.toString() ?? '—',
              style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Glass.text),
            ),
          ),
          Expanded(
            child: Text(
              entry['endpoint']?.toString() ?? '—',
              style: TextStyle(
                fontSize: 12.5,
                fontFamily: 'monospace',
                color: err ? Glass.danger : Glass.text,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${entry['numQueries'] ?? 0}',
              style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: Glass.textSubtle),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              duration == null ? '—' : '${duration.toStringAsFixed(0)}ms',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: slow ? Glass.auroraC : Glass.textSubtle,
              ),
            ),
          ),
          SizedBox(
            width: 20,
            child: err
                ? const Icon(Icons.error_outline,
                    size: 13, color: Glass.danger)
                : null,
          ),
        ],
      ),
    );
  }

  String _fmtTime(dynamic v) {
    if (v == null) return '—';
    DateTime? t;
    if (v is DateTime) t = v;
    if (v is String) t = DateTime.tryParse(v);
    if (t == null) return v.toString();
    final local = t.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final ss = local.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}
