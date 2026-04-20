import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';
import '../../main.dart' show client;
import '../../theme.dart';
import '../widgets/id_badge.dart';
import '../widgets/field_icon.dart';
import '../widgets/empty_state.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late Future<List<Post>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _future = client.posts.listPosts();
  }

  void _refresh() {
    setState(() {
      _future = client.posts.listPosts();
    });
  }

  Future<void> _create() async {
    final result = await showDialog<({String title, String body})>(
      context: context,
      builder: (_) => const _NewPostDialog(),
    );
    if (result == null || result.title.trim().isEmpty) return;
    await client.posts.createPost(result.title, result.body);
    _refresh();
  }

  Future<void> _delete(Post p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete post?'),
        content: Text('"${p.title}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Tokens.danger, foregroundColor: Colors.black),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await client.posts.deletePost(p.id!);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeaderBar(onRefresh: _refresh),
        _FilterBar(
          onSearchChanged: (v) => setState(() => _search = v.toLowerCase()),
          onNew: _create,
        ),
        Expanded(
          child: FutureBuilder<List<Post>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const LoadingState();
              }
              if (snap.hasError) {
                return ErrorStateView(error: snap.error!, onRetry: _refresh);
              }
              final all = snap.data ?? [];
              final rows = _search.isEmpty
                  ? all
                  : all
                      .where((p) =>
                          p.title.toLowerCase().contains(_search) ||
                          p.body.toLowerCase().contains(_search))
                      .toList();
              if (all.isEmpty) {
                return EmptyState(
                  icon: Icons.description_outlined,
                  title: 'No records yet',
                  subtitle: 'Create your first post to get started.',
                  action: FilledButton.icon(
                    onPressed: _create,
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('New record'),
                  ),
                );
              }
              if (rows.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'No matches',
                  subtitle: 'Try a different search term.',
                );
              }
              return _RecordsTable(
                posts: rows,
                totalCount: all.length,
                onDelete: _delete,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final VoidCallback onRefresh;
  const _HeaderBar({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Tokens.topbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Tokens.border)),
      ),
      child: Row(
        children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: 'Collections  ',
                  style: TextStyle(color: Tokens.textMuted, fontSize: 13)),
              TextSpan(
                  text: '›  ',
                  style: TextStyle(color: Tokens.textMuted, fontSize: 13)),
              TextSpan(
                  text: 'posts',
                  style: TextStyle(
                      color: Tokens.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Collection settings',
            icon: const Icon(Icons.tune, size: 16),
            onPressed: () {},
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: onRefresh,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNew;
  const _FilterBar({required this.onSearchChanged, required this.onNew});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Tokens.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 34,
              child: TextField(
                onChanged: onSearchChanged,
                style: const TextStyle(fontSize: 13, color: Tokens.textPrimary),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 16, color: Tokens.textMuted),
                  prefixIconConstraints:
                      BoxConstraints(minWidth: 34, minHeight: 34),
                  hintText: 'Search term or filter…',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 34,
            child: FilledButton.icon(
              onPressed: onNew,
              icon: const Icon(Icons.add, size: 14),
              label: const Text('New record'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordsTable extends StatelessWidget {
  final List<Post> posts;
  final int totalCount;
  final void Function(Post) onDelete;

  const _RecordsTable({
    required this.posts,
    required this.totalCount,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeaderRow(),
        Expanded(
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, i) => _DataRow(post: posts[i], onDelete: onDelete),
          ),
        ),
        _FooterBar(visible: posts.length, total: totalCount),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Tokens.headerHeight,
      decoration: const BoxDecoration(
        color: Tokens.surface,
        border: Border(bottom: BorderSide(color: Tokens.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: const [
          SizedBox(width: 20),
          _HCell(width: 120, icon: FieldType.id, label: 'id'),
          _HCell(width: 260, icon: FieldType.text, label: 'title'),
          Expanded(child: _HCell(width: 0, icon: FieldType.longText, label: 'body')),
          _HCell(width: 160, icon: FieldType.datetime, label: 'createdAt'),
          SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _HCell extends StatelessWidget {
  final double width;
  final FieldType icon;
  final String label;
  const _HCell({required this.width, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        FieldIcon(icon),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Tokens.textSecondary)),
      ],
    );
    if (width == 0) return content;
    return SizedBox(width: width, child: content);
  }
}

class _DataRow extends StatefulWidget {
  final Post post;
  final void Function(Post) onDelete;
  const _DataRow({required this.post, required this.onDelete});

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        height: Tokens.rowHeight,
        decoration: BoxDecoration(
          color: _hover ? Tokens.elevated : Tokens.bg,
          border: const Border(
              bottom: BorderSide(color: Tokens.borderSubtle)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const SizedBox(width: 20),
            SizedBox(width: 120, child: IdBadge('${widget.post.id}')),
            SizedBox(
              width: 260,
              child: Text(widget.post.title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Tokens.textPrimary,
                      fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(widget.post.body,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, color: Tokens.textSecondary)),
            ),
            SizedBox(
              width: 160,
              child: Text(_formatDate(widget.post.createdAt),
                  style: const TextStyle(
                      fontFamily: Tokens.monoFamily,
                      fontSize: 12,
                      color: Tokens.textMuted,
                      fontFeatures: [FontFeature.tabularFigures()])),
            ),
            SizedBox(
              width: 40,
              child: _hover
                  ? IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline, size: 16),
                      color: Tokens.textSecondary,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => widget.onDelete(widget.post),
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
  final now = DateTime.now();
  final diff = now.difference(local);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class _FooterBar extends StatelessWidget {
  final int visible;
  final int total;
  const _FooterBar({required this.visible, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Tokens.surface,
        border: Border(top: BorderSide(color: Tokens.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            visible == total
                ? 'Total $total'
                : 'Showing $visible of $total',
            style: const TextStyle(
                fontSize: 12, color: Tokens.textMuted),
          ),
          const Spacer(),
          const _PageControl(),
        ],
      ),
    );
  }
}

class _PageControl extends StatelessWidget {
  const _PageControl();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, size: 16),
          onPressed: null,
          visualDensity: VisualDensity.compact,
          disabledColor: Tokens.textMuted,
        ),
        const Text('1',
            style: TextStyle(
                fontFamily: Tokens.monoFamily,
                fontSize: 12,
                color: Tokens.textSecondary)),
        IconButton(
          icon: const Icon(Icons.chevron_right, size: 16),
          onPressed: null,
          visualDensity: VisualDensity.compact,
          disabledColor: Tokens.textMuted,
        ),
      ],
    );
  }
}

class _NewPostDialog extends StatefulWidget {
  const _NewPostDialog();

  @override
  State<_NewPostDialog> createState() => _NewPostDialogState();
}

class _NewPostDialogState extends State<_NewPostDialog> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      contentPadding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      title: Row(
        children: [
          const Icon(Icons.add_circle_outline, size: 16, color: Tokens.accent),
          const SizedBox(width: 8),
          const Text('New record', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Tokens.elevated,
              borderRadius: BorderRadius.circular(Tokens.radiusSm),
              border: Border.all(color: Tokens.border),
            ),
            child: const Text('posts',
                style: TextStyle(
                    fontFamily: Tokens.monoFamily,
                    fontSize: 11,
                    color: Tokens.textMuted)),
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('title', required: true),
            const SizedBox(height: 6),
            TextField(
              controller: _title,
              autofocus: true,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Enter title…'),
            ),
            const SizedBox(height: 16),
            const _FieldLabel('body'),
            const SizedBox(height: 6),
            TextField(
              controller: _body,
              maxLines: 5,
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Enter body…'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context)
              .pop((title: _title.text, body: _body.text)),
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel(this.label, {this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Tokens.textSecondary,
                letterSpacing: 0.2)),
        if (required) ...[
          const SizedBox(width: 4),
          const Text('*', style: TextStyle(color: Tokens.danger, fontSize: 12)),
        ],
      ],
    );
  }
}
