import 'package:flutter/material.dart';
import '../theme.dart';

enum NavSection { collections, logs, settings }

class NavRail extends StatelessWidget {
  final NavSection section;
  final ValueChanged<NavSection> onSectionChanged;
  final String? selectedCollection;
  final List<CollectionEntry> collections;
  final ValueChanged<String> onSelectCollection;
  final VoidCallback onNewCollection;
  final String? adminEmail;
  final VoidCallback onSignOut;

  const NavRail({
    super.key,
    required this.section,
    required this.onSectionChanged,
    required this.selectedCollection,
    required this.collections,
    required this.onSelectCollection,
    required this.onNewCollection,
    required this.adminEmail,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Tokens.railWidth,
      color: Tokens.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BrandRow(),
          const Divider(height: 1),
          _NavTab(
            icon: Icons.storage_rounded,
            label: 'Collections',
            selected: section == NavSection.collections,
            onTap: () => onSectionChanged(NavSection.collections),
          ),
          _NavTab(
            icon: Icons.receipt_long_outlined,
            label: 'Logs',
            selected: section == NavSection.logs,
            onTap: () => onSectionChanged(NavSection.logs),
          ),
          _NavTab(
            icon: Icons.settings_outlined,
            label: 'Settings',
            selected: section == NavSection.settings,
            onTap: () => onSectionChanged(NavSection.settings),
          ),
          const Divider(height: 1),
          if (section == NavSection.collections) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 14, 14, 6),
              child: Text('COLLECTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: Tokens.textMuted,
                  )),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                itemCount: collections.length,
                itemBuilder: (_, i) {
                  final c = collections[i];
                  return _CollectionTile(
                    entry: c,
                    selected: c.name == selectedCollection,
                    onTap: () => onSelectCollection(c.name),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 34,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onNewCollection,
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('New collection'),
                ),
              ),
            ),
          ] else
            const Expanded(child: SizedBox.shrink()),
          const Divider(height: 1),
          _AdminFooter(email: adminEmail, onSignOut: onSignOut),
        ],
      ),
    );
  }
}

class _AdminFooter extends StatefulWidget {
  final String? email;
  final VoidCallback onSignOut;
  const _AdminFooter({required this.email, required this.onSignOut});

  @override
  State<_AdminFooter> createState() => _AdminFooterState();
}

class _AdminFooterState extends State<_AdminFooter> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final initials = _initialsOf(widget.email ?? '?');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: OutlinedButton.icon(
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout, size: 14),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(32),
              ),
            ),
          ),
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    color: Tokens.elevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Tokens.border),
                  ),
                  alignment: Alignment.center,
                  child: Text(initials,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Tokens.textSecondary)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('admin',
                          style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.6,
                              color: Tokens.textMuted,
                              fontWeight: FontWeight.w600)),
                      Text(widget.email ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Tokens.textPrimary,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Icon(_open ? Icons.expand_more : Icons.expand_less,
                    size: 16, color: Tokens.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _initialsOf(String email) {
    final at = email.indexOf('@');
    final name = at > 0 ? email.substring(0, at) : email;
    if (name.isEmpty) return '?';
    final parts = name.split(RegExp(r'[._-]')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

class _BrandRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Tokens.topbarHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: Tokens.accent,
                borderRadius: BorderRadius.circular(Tokens.radiusSm),
              ),
              alignment: Alignment.center,
              child: const Text('S',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5)),
            ),
            const SizedBox(width: 10),
            const Text('Serverpod Lite',
                style: TextStyle(
                    color: Tokens.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Tokens.elevated,
                borderRadius: BorderRadius.circular(Tokens.radiusSm),
                border: Border.all(color: Tokens.border),
              ),
              child: const Text('dev',
                  style: TextStyle(
                      fontFamily: Tokens.monoFamily,
                      fontSize: 10,
                      color: Tokens.textMuted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavTab> createState() => _NavTabState();
}

class _NavTabState extends State<_NavTab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? Tokens.hover
        : (_hover ? Tokens.elevated : Colors.transparent);
    final color = widget.selected || _hover
        ? Tokens.textPrimary
        : Tokens.textSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 36,
          margin: const EdgeInsets.fromLTRB(6, 2, 6, 2),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(Tokens.radiusMd),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: color),
              const SizedBox(width: 10),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight:
                          widget.selected ? FontWeight.w600 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectionEntry {
  final String name;
  final IconData icon;
  final int? count;
  const CollectionEntry(this.name, {required this.icon, this.count});
}

class _CollectionTile extends StatefulWidget {
  final CollectionEntry entry;
  final bool selected;
  final VoidCallback onTap;
  const _CollectionTile({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CollectionTile> createState() => _CollectionTileState();
}

class _CollectionTileState extends State<_CollectionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? Tokens.hover
        : (_hover ? Tokens.elevated : Colors.transparent);
    final color = widget.selected || _hover
        ? Tokens.textPrimary
        : Tokens.textSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 32,
          margin: const EdgeInsets.symmetric(vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(Tokens.radiusSm),
          ),
          child: Row(
            children: [
              Icon(widget.entry.icon, size: 14, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.entry.name,
                    style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: widget.selected
                            ? FontWeight.w600
                            : FontWeight.w500)),
              ),
              if (widget.entry.count != null)
                Text('${widget.entry.count}',
                    style: const TextStyle(
                        fontFamily: Tokens.monoFamily,
                        fontSize: 11,
                        color: Tokens.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
