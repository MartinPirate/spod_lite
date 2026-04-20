import 'package:flutter/material.dart';
import '../dashboard/shell.dart';
import '../theme.dart';
import '../dashboard/widgets/empty_state.dart';
import 'auth_state.dart';
import 'sign_in_screen.dart';

class AuthGate extends StatefulWidget {
  final AuthState state;
  const AuthGate({super.key, required this.state});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onChange);
    widget.state.bootstrap();
  }

  @override
  void dispose() {
    widget.state.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    switch (widget.state.status) {
      case AuthStatus.loading:
        return const Scaffold(
          backgroundColor: Tokens.bg,
          body: LoadingState(),
        );
      case AuthStatus.serverDown:
        return Scaffold(
          backgroundColor: Tokens.bg,
          body: EmptyState(
            icon: Icons.cloud_off_outlined,
            title: 'Server unreachable',
            subtitle: widget.state.error,
            action: FilledButton.icon(
              onPressed: () => widget.state.bootstrap(),
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Retry'),
            ),
          ),
        );
      case AuthStatus.bootstrap:
        return SignInScreen(state: widget.state, isBootstrap: true);
      case AuthStatus.signedOut:
        return SignInScreen(state: widget.state, isBootstrap: false);
      case AuthStatus.signedIn:
        return DashboardShell(auth: widget.state);
    }
  }
}
