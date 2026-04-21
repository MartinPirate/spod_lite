import 'package:flutter/material.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import '../../glass.dart';
import '../../main.dart' show client;

/// Admin screen for OAuth provider credentials.
///
/// Shows every provider the server *knows how to speak* (via
/// `availableProviders`) whether or not it's configured yet. Unconfigured
/// providers are a dashed outline with an "Add credentials" button;
/// configured providers show status + edit/delete. Matches the dashboard's
/// slate aesthetic — no glass blur, solid surfaces, high-density table.
class OAuthScreen extends StatefulWidget {
  const OAuthScreen({super.key});

  @override
  State<OAuthScreen> createState() => _OAuthScreenState();
}

class _OAuthScreenState extends State<OAuthScreen> {
  List<String> _available = [];
  List<OAuthProviderConfig> _configs = [];
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        client.oAuthConfig.availableProviders(),
        client.oAuthConfig.list(),
      ]);
      if (!mounted) return;
      setState(() {
        _available = (results[0] as List).cast<String>();
        _configs = (results[1] as List).cast<OAuthProviderConfig>();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _configure(String provider) async {
    final existing = _configs.firstWhere(
      (c) => c.provider == provider,
      orElse: () => OAuthProviderConfig(
        provider: provider,
        clientId: '',
        clientSecret: '',
        enabled: true,
      ),
    );
    final result = await showDialog<_ProviderFormResult>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => _ProviderFormDialog(
        provider: provider,
        existing: existing,
        isNew: existing.id == null,
      ),
    );
    if (result == null) return;
    try {
      await client.oAuthConfig.save(
        result.provider,
        result.clientId,
        result.clientSecret,
        result.enabled,
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      _snack('Save failed: ${_message(e)}');
    }
  }

  Future<void> _delete(OAuthProviderConfig config) async {
    final ok = await _confirmDelete(config.provider);
    if (ok != true) return;
    try {
      await client.oAuthConfig.delete(config.provider);
      await _load();
    } catch (e) {
      if (!mounted) return;
      _snack('Delete failed: ${_message(e)}');
    }
  }

  Future<bool?> _confirmDelete(String provider) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Glass.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Glass.hairline),
          ),
          title: Text('Delete $provider config?',
              style: const TextStyle(color: Glass.text)),
          content: Text(
            'Users who already linked $provider stay linked; they just '
            'can\'t sign in again until you set up credentials.',
            style: const TextStyle(color: Glass.textMuted, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel',
                  style: TextStyle(color: Glass.textSubtle)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: Glass.danger)),
            ),
          ],
        ),
      );

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Glass.surface,
        behavior: SnackBarBehavior.floating,
        content: Text(msg, style: const TextStyle(color: Glass.text)),
      ),
    );
  }

  String _message(Object e) {
    try {
      final m = (e as dynamic).message;
      if (m is String && m.isNotEmpty) return m;
    } catch (_) {}
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    final byProvider = {for (final c in _configs) c.provider: c};
    return Column(
      children: [
        _SectionHeader(
          icon: Icons.key_outlined,
          title: 'OAuth providers',
          subtitle:
              'Sign-in-with-… credentials. Store client id and secret per provider; SDK pulls the list from /oauth.',
          onRefresh: _load,
        ),
        Expanded(
          child: _loading
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Glass.accent),
                    ),
                  ),
                )
              : _error != null
                  ? Center(
                      child: Text('$_error',
                          style: const TextStyle(color: Glass.textMuted)),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                      child: _available.isEmpty
                          ? const _EmptyRegistry()
                          : ListView.separated(
                              itemCount: _available.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) {
                                final id = _available[i];
                                final config = byProvider[id];
                                return _ProviderCard(
                                  provider: id,
                                  config: config,
                                  onConfigure: () => _configure(id),
                                  onDelete: config == null
                                      ? null
                                      : () => _delete(config),
                                );
                              },
                            ),
                    ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String provider;
  final OAuthProviderConfig? config;
  final VoidCallback onConfigure;
  final VoidCallback? onDelete;

  const _ProviderCard({
    required this.provider,
    required this.config,
    required this.onConfigure,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final configured = config != null;
    final hasSecret =
        (config?.clientSecret ?? '').isNotEmpty;
    final enabled = config?.enabled ?? false;

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Glass.hairline),
            ),
            alignment: Alignment.center,
            child: Text(
              _initialFor(provider),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Glass.text,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_labelFor(provider),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Glass.text)),
                    const SizedBox(width: 8),
                    _StatusPill(
                      configured: configured,
                      enabled: enabled,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  configured
                      ? 'Client id ${_shorten(config!.clientId)}'
                          '${hasSecret ? " · secret stored" : " · no secret"}'
                      : 'Not configured — add a client id and secret to enable.',
                  style: const TextStyle(
                      fontSize: 12, color: Glass.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (configured && onDelete != null) ...[
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 15),
              color: Glass.textSubtle,
              tooltip: 'Delete',
              visualDensity: VisualDensity.compact,
              onPressed: onDelete,
            ),
            const SizedBox(width: 4),
          ],
          SizedBox(
            width: 130,
            height: 34,
            child: LiquidButton(
              onPressed: onConfigure,
              height: 34,
              subtle: configured,
              child: Text(configured ? 'Edit' : 'Add credentials'),
            ),
          ),
        ],
      ),
    );
  }

  String _initialFor(String provider) {
    if (provider.isEmpty) return '?';
    return provider.substring(0, 1).toUpperCase();
  }

  String _labelFor(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'github':
        return 'GitHub';
      case 'apple':
        return 'Apple';
      default:
        return provider;
    }
  }

  String _shorten(String clientId) {
    if (clientId.length <= 22) return clientId;
    return '${clientId.substring(0, 10)}…${clientId.substring(clientId.length - 8)}';
  }
}

class _StatusPill extends StatelessWidget {
  final bool configured;
  final bool enabled;
  const _StatusPill({required this.configured, required this.enabled});

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFFBBF24);
    final (label, color) = !configured
        ? ('not set', Glass.textFaint)
        : enabled
            ? ('enabled', Glass.accent)
            : ('disabled', amber);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _EmptyRegistry extends StatelessWidget {
  const _EmptyRegistry();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassPanel(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.key_outlined, size: 32, color: Glass.textFaint),
            SizedBox(height: 10),
            Text('No OAuth providers are compiled in.',
                style: TextStyle(color: Glass.text, fontSize: 14)),
            SizedBox(height: 4),
            Text(
              'Add a class to lib/src/oauth/providers/ and register it in OAuthRegistry.',
              style: TextStyle(color: Glass.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Glass.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Glass.text)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Glass.textMuted)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 16),
              color: Glass.textMuted,
              onPressed: onRefresh,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderFormResult {
  final String provider;
  final String clientId;
  final String clientSecret;
  final bool enabled;
  _ProviderFormResult({
    required this.provider,
    required this.clientId,
    required this.clientSecret,
    required this.enabled,
  });
}

class _ProviderFormDialog extends StatefulWidget {
  final String provider;
  final OAuthProviderConfig existing;
  final bool isNew;
  const _ProviderFormDialog({
    required this.provider,
    required this.existing,
    required this.isNew,
  });

  @override
  State<_ProviderFormDialog> createState() => _ProviderFormDialogState();
}

class _ProviderFormDialogState extends State<_ProviderFormDialog> {
  late final TextEditingController _clientId;
  late final TextEditingController _clientSecret;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _clientId = TextEditingController(text: widget.existing.clientId);
    _clientSecret = TextEditingController();
    _enabled = widget.existing.enabled;
  }

  @override
  void dispose() {
    _clientId.dispose();
    _clientSecret.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasStoredSecret =
        !widget.isNew && (widget.existing.clientSecret ?? '').isNotEmpty;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GlassPanel(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.key_outlined,
                      size: 18, color: Glass.accent),
                  const SizedBox(width: 10),
                  Text(
                    widget.isNew
                        ? 'Add ${_labelFor(widget.provider)} credentials'
                        : 'Edit ${_labelFor(widget.provider)} credentials',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Glass.text),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    color: Glass.textSubtle,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _helperFor(widget.provider),
                style: const TextStyle(
                    fontSize: 12, color: Glass.textMuted, height: 1.5),
              ),
              const SizedBox(height: 18),
              GlassField(
                controller: _clientId,
                label: 'CLIENT ID',
                leading: Icons.badge_outlined,
                hint: '123.apps.googleusercontent.com',
              ),
              const SizedBox(height: 12),
              GlassField(
                controller: _clientSecret,
                label: 'CLIENT SECRET',
                leading: Icons.lock_outline,
                obscureText: true,
                hint: hasStoredSecret
                    ? 'leave blank to keep the stored secret'
                    : 'from the provider console',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Switch(
                    value: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                    activeThumbColor: Glass.accent,
                  ),
                  const SizedBox(width: 8),
                  const Text('Enabled',
                      style: TextStyle(color: Glass.text, fontSize: 13)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Toggle off to take this provider out of listProviders() without losing the credentials.',
                      style:
                          TextStyle(color: Glass.textFaint, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 100,
                    child: LiquidButton(
                      subtle: true,
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: LiquidButton(
                      onPressed: _save,
                      child: Text(widget.isNew ? 'Save' : 'Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    final id = _clientId.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Glass.surface,
          behavior: SnackBarBehavior.floating,
          content:
              Text('Client ID is required.', style: TextStyle(color: Glass.text)),
        ),
      );
      return;
    }
    if (widget.isNew && _clientSecret.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Glass.surface,
          behavior: SnackBarBehavior.floating,
          content: Text('Client secret is required on first save.',
              style: TextStyle(color: Glass.text)),
        ),
      );
      return;
    }
    Navigator.of(context).pop(_ProviderFormResult(
      provider: widget.provider,
      clientId: id,
      clientSecret: _clientSecret.text,
      enabled: _enabled,
    ));
  }

  String _labelFor(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'github':
        return 'GitHub';
      case 'apple':
        return 'Apple';
      default:
        return provider;
    }
  }

  String _helperFor(String provider) {
    switch (provider) {
      case 'google':
        return 'Create an OAuth 2.0 Web Application client at '
            'console.cloud.google.com/apis/credentials. Your redirect '
            'URI must match the one your app passes to getAuthUrl.';
      default:
        return 'Paste the client id and secret from this provider\'s '
            'developer console.';
    }
  }
}
