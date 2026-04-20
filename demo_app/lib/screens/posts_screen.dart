import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../main.dart' show spod;
import '../theme.dart';

class PostsScreen extends StatefulWidget {
  final VoidCallback onSignOut;
  const PostsScreen({super.key, required this.onSignOut});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = spod.client.posts.listPosts();
  }

  void _refresh() => setState(() {
        _future = spod.client.posts.listPosts();
      });

  Future<void> _create() async {
    final result = await showGeneralDialog<({String title, String body})>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'New post',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) => const Center(child: _NewPostDialog()),
      transitionBuilder: (_, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.94, end: 1.0).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
    if (result == null || result.title.trim().isEmpty) return;
    try {
      await spod.client.posts.createPost(result.title, result.body);
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Glass.bgSoft,
          behavior: SnackBarBehavior.floating,
          content: Text('Could not create post: $e',
              style: const TextStyle(color: Glass.text)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(onRefresh: _refresh, onSignOut: widget.onSignOut),
              Expanded(
                child: FutureBuilder<List<Post>>(
                  future: _future,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const _Loading();
                    }
                    if (snap.hasError) {
                      return _ErrorView(
                          error: snap.error!, onRetry: _refresh);
                    }
                    final posts = snap.data ?? [];
                    if (posts.isEmpty) return _Empty(onCreate: _create);
                    return _Feed(posts: posts);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 12, bottom: 12),
        child: SizedBox(
          height: 54,
          width: 160,
          child: LiquidButton(
            onPressed: _create,
            height: 54,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 15),
                SizedBox(width: 8),
                Text('New post'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onSignOut;
  const _TopBar({required this.onRefresh, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: RiseIn(
        child: GlassPanel(
          radius: 18,
          blur: 30,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              const LiquidMark(size: 30),
              const SizedBox(width: 10),
              const Text('Spod',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: Glass.text)),
              const SizedBox(width: 10),
              _LiveDot(),
              const Spacer(),
              _GlassIcon(
                  icon: Icons.refresh, tooltip: 'Refresh', onTap: onRefresh),
              const SizedBox(width: 6),
              _UserChip(onSignOut: onSignOut),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Glass.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(alignment: Alignment.center, children: [
            AnimatedBuilder(
              animation: _c,
              builder: (_, _) {
                final s = 4 + 8 * _c.value;
                return Container(
                  width: s, height: s,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Glass.auroraD
                        .withValues(alpha: 0.5 * (1 - _c.value)),
                  ),
                );
              },
            ),
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Glass.auroraD,
              ),
            ),
          ]),
          const SizedBox(width: 7),
          const Text('LIVE',
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                  color: Glass.text)),
        ],
      ),
    );
  }
}

class _GlassIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _GlassIcon(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  State<_GlassIcon> createState() => _GlassIconState();
}

class _GlassIconState extends State<_GlassIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _hover ? Glass.surfaceHover : Glass.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _hover ? Glass.hairlineStrong : Glass.hairline),
            ),
            child: Icon(widget.icon,
                size: 16,
                color: _hover ? Glass.text : Glass.textMuted),
          ),
        ),
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  final VoidCallback onSignOut;
  const _UserChip({required this.onSignOut});

  String _initials(String email) {
    final at = email.indexOf('@');
    final name = at > 0 ? email.substring(0, at) : email;
    if (name.isEmpty) return '?';
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final email = spod.userAuth.currentUser?.email ?? '';
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 46),
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      menuPadding: EdgeInsets.zero,
      onSelected: (v) {
        if (v == 'signout') onSignOut();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            width: 220,
            decoration: BoxDecoration(
              color: Glass.bgSoft.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: Border.all(color: Glass.hairline),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signed in as',
                    style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w600,
                        color: Glass.textFaint)),
                const SizedBox(height: 4),
                Text(email,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Glass.text)),
              ],
            ),
          ),
        ),
        PopupMenuItem(
          value: 'signout',
          padding: EdgeInsets.zero,
          child: Container(
            width: 220,
            decoration: BoxDecoration(
              color: Glass.bgSoft.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border(
                left: BorderSide(color: Glass.hairline),
                right: BorderSide(color: Glass.hairline),
                bottom: BorderSide(color: Glass.hairline),
              ),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: const [
                Icon(Icons.logout, size: 14, color: Glass.textMuted),
                SizedBox(width: 10),
                Text('Sign out',
                    style: TextStyle(
                        fontSize: 13,
                        color: Glass.text,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          gradient: const LinearGradient(
            colors: [Glass.auroraA, Glass.auroraB],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Glass.auroraB.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          _initials(email),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  final List<Post> posts;
  const _Feed({required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 120),
      itemCount: posts.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        if (i == 0) {
          return RiseIn(
            delay: const Duration(milliseconds: 80),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6, left: 4),
              child: Row(
                children: [
                  const Text('Feed',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1.0,
                          color: Glass.text)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Glass.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Glass.hairline),
                    ),
                    child: Text('${posts.length}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Glass.textMuted,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          );
        }
        return RiseIn(
          delay: Duration(milliseconds: 60 * i),
          child: _PostCard(post: posts[i - 1]),
        );
      },
    );
  }
}

class _PostCard extends StatefulWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.005 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: GlassPanel(
          radius: 20,
          blur: 36,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(widget.post.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                          color: Glass.text,
                        )),
                  ),
                  const SizedBox(width: 12),
                  Text(_relative(widget.post.createdAt),
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: Glass.textFaint,
                          fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
              const SizedBox(height: 8),
              Text(widget.post.body,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Glass.textMuted,
                      height: 1.55)),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Glass.hairline),
                    ),
                    child: Text('#${widget.post.id}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Glass.textSubtle,
                          fontFamily: 'monospace',
                        )),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.bolt,
                      size: 11, color: Glass.textFaint),
                  const SizedBox(width: 3),
                  const Text('posts',
                      style: TextStyle(
                          fontSize: 11, color: Glass.textFaint)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _relative(DateTime? dt) {
  if (dt == null) return '';
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Glass.accent),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final VoidCallback onCreate;
  const _Empty({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RiseIn(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: GlassPanel(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LiquidMark(size: 52),
                const SizedBox(height: 18),
                const Text('Nothing here yet',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: Glass.text)),
                const SizedBox(height: 6),
                const Text(
                  'Posts you write appear here instantly. They live on your own Serverpod Lite backend.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Glass.textMuted, fontSize: 13.5, height: 1.55),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: 200,
                  child: LiquidButton(
                    onPressed: onCreate,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 14),
                        SizedBox(width: 8),
                        Text('Write first post'),
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

class _ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RiseIn(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: GlassPanel(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52, height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Glass.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Glass.danger.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.error_outline,
                      size: 22, color: Glass.danger),
                ),
                const SizedBox(height: 18),
                const Text('Could not load feed',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Glass.text)),
                const SizedBox(height: 6),
                Text(error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12.5,
                        color: Glass.textMuted,
                        height: 1.5)),
                const SizedBox(height: 20),
                SizedBox(
                  width: 140,
                  child: LiquidButton(
                    onPressed: onRetry,
                    subtle: true,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 14),
                        SizedBox(width: 6),
                        Text('Retry'),
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
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: GlassPanel(
            radius: 24,
            blur: 50,
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const LiquidMark(size: 34),
                    const SizedBox(width: 12),
                    const Text('New post',
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
                const SizedBox(height: 18),
                GlassField(
                  controller: _title,
                  label: 'TITLE',
                  leading: Icons.edit,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                GlassField(
                  controller: _body,
                  label: 'BODY',
                  hint: 'What\'s on your mind?',
                  leading: Icons.subject,
                ),
                const SizedBox(height: 22),
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
                        onPressed: () => Navigator.of(context).pop(
                          (title: _title.text, body: _body.text),
                        ),
                        child: const Text('Publish'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
