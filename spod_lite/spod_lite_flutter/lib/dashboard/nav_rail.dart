import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../glass.dart';

enum NavSection { collections, admins, users, logs, emails }

class NavRail extends StatelessWidget {
  final NavSection section;
  final ValueChanged<NavSection> onSectionChanged;
  final List<CollectionDef> collections;
  final bool collectionsLoading;
  final String? selectedCollectionName;
  final ValueChanged<CollectionDef> onSelectCollection;
  final VoidCallback onNewCollection;
  final VoidCallback onRefreshCollections;
  final String? adminEmail;
  final VoidCallback onSignOut;

  const NavRail({
    super.key,
    required this.section,
    required this.onSectionChanged,
    required this.collections,
    required this.collectionsLoading,
    required this.selectedCollectionName,
    required this.onSelectCollection,
    required this.onNewCollection,
    required this.onRefreshCollections,
    required this.adminEmail,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 20,
      blur: 40,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Brand(),
          const Divider(height: 1, color: Glass.hairline),
          _Tab(
            icon: Icons.storage_rounded,
            label: 'Collections',
            selected: section == NavSection.collections,
            onTap: () => onSectionChanged(NavSection.collections),
          ),
          _Tab(
            icon: Icons.shield_moon_outlined,
            label: 'Admins',
            selected: section == NavSection.admins,
            onTap: () => onSectionChanged(NavSection.admins),
          ),
          _Tab(
            icon: Icons.people_outline_rounded,
            label: 'Users',
            selected: section == NavSection.users,
            onTap: () => onSectionChanged(NavSection.users),
          ),
          _Tab(
            icon: Icons.receipt_long_outlined,
            label: 'Logs',
            selected: section == NavSection.logs,
            onTap: () => onSectionChanged(NavSection.logs),
          ),
          _Tab(
            icon: Icons.mail_outline_rounded,
            label: 'Emails',
            selected: section == NavSection.emails,
            onTap: () => onSectionChanged(NavSection.emails),
          ),
          const Divider(height: 1, color: Glass.hairline),
          if (section == NavSection.collections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
              child: Row(
                children: [
                  const Text('COLLECTIONS',
                      style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          color: Glass.textFaint)),
                  const Spacer(),
                  InkWell(
                    onTap: onRefreshCollections,
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.refresh,
                          size: 12, color: Glass.textFaint),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _collectionsList()),
            const Divider(height: 1, color: Glass.hairline),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: 36,
                child: LiquidButton(
                  onPressed: onNewCollection,
                  height: 36,
                  subtle: true,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 13),
                      SizedBox(width: 6),
                      Text('New collection'),
                    ],
                  ),
                ),
              ),
            ),
          ] else
            const Expanded(child: SizedBox.shrink()),
          const Divider(height: 1, color: Glass.hairline),
          _Footer(email: adminEmail, onSignOut: onSignOut),
        ],
      ),
    );
  }

  Widget _collectionsList() {
    if (collectionsLoading && collections.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Center(
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Glass.textFaint),
            ),
          ),
        ),
      );
    }
    if (collections.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Text(
          'No collections yet.\nClick "New collection" to create one.',
          style: TextStyle(
              fontSize: 11.5, color: Glass.textFaint, height: 1.5),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      itemCount: collections.length,
      itemBuilder: (_, i) {
        final c = collections[i];
        return _CollectionTile(
          def: c,
          selected: c.name == selectedCollectionName,
          onTap: () => onSelectCollection(c),
        );
      },
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const LiquidMark(size: 28),
            const SizedBox(width: 12),
            const Text('Serverpod Lite',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: Glass.text)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Glass.hairline),
              ),
              child: const Text('dev',
                  style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Glass.textFaint)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? Colors.white.withValues(alpha: 0.10)
        : (_hover ? Colors.white.withValues(alpha: 0.05) : Colors.transparent);
    final color =
        widget.selected || _hover ? Glass.text : Glass.textSubtle;

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
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 15, color: color),
              const SizedBox(width: 10),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: widget.selected
                          ? FontWeight.w600
                          : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionTile extends StatefulWidget {
  final CollectionDef def;
  final bool selected;
  final VoidCallback onTap;

  const _CollectionTile({
    required this.def,
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
        ? Colors.white.withValues(alpha: 0.10)
        : (_hover ? Colors.white.withValues(alpha: 0.05) : Colors.transparent);
    final color =
        widget.selected || _hover ? Glass.text : Glass.textSubtle;

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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.description_outlined, size: 13, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.def.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: widget.selected
                            ? FontWeight.w600
                            : FontWeight.w500)),
              ),
              if (widget.selected || _hover)
                Text(widget.def.name,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: Glass.textFaint)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatefulWidget {
  final String? email;
  final VoidCallback onSignOut;
  const _Footer({required this.email, required this.onSignOut});

  @override
  State<_Footer> createState() => _FooterState();
}

class _FooterState extends State<_Footer> {
  bool _open = false;

  String _initials(String email) {
    final at = email.indexOf('@');
    final name = at > 0 ? email.substring(0, at) : email;
    if (name.isEmpty) return '?';
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.email ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: SizedBox(
              height: 32,
              child: LiquidButton(
                onPressed: widget.onSignOut,
                height: 32,
                subtle: true,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 12),
                    SizedBox(width: 6),
                    Text('Sign out',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
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
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [Glass.auroraA, Glass.auroraB],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Glass.auroraB.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(_initials(email),
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('admin',
                          style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 0.6,
                              color: Glass.textFaint,
                              fontWeight: FontWeight.w700)),
                      Text(email,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Glass.text,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Icon(_open ? Icons.expand_more : Icons.expand_less,
                    size: 15, color: Glass.textFaint),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
