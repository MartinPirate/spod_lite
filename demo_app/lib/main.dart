import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:spod_lite_client/spod_lite_client.dart';
import 'package:spod_lite_sdk/spod_lite_sdk.dart';

import 'screens/posts_screen.dart';
import 'screens/sign_in_screen.dart';
import 'theme.dart';

late final SpodLite<Client> spod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  spod = SpodLite<Client>(
    createClient: () => Client('http://localhost:8088/')
      ..connectivityMonitor = FlutterConnectivityMonitor(),
    adminEndpoint: (c) => c.adminAuth,
    userAuthEndpoint: (c) => c.userAuth,
    collectionsEndpoint: (c) => c.collections,
    recordsEndpoint: (c) => c.records,
    filesEndpoint: (c) => c.files,
    oauthEndpoint: (c) => c.oAuth,
  );
  await _consumeOAuthRedirectIfPresent();
  await spod.userAuth.restore();
  runApp(const DemoApp());
}

/// If the app was just redirected back from a provider's consent
/// screen, finish the flow before the UI mounts. We detect the redirect
/// by looking for `state` + `code` in the current URL — Google's
/// standard OAuth2 callback params — and hand them to the SDK. Once
/// consumed we rely on SpodLite.userAuth.restore to populate the rest.
Future<void> _consumeOAuthRedirectIfPresent() async {
  final uri = Uri.base;
  final state = uri.queryParameters['state'];
  final code = uri.queryParameters['code'];
  if (state == null || code == null) return;
  try {
    // Provider id isn't sent on the callback — we only ship Google
    // today, so assume that. When we add more providers we'll either
    // encode the provider into state or let the server derive it from
    // the stored flow metadata.
    await spod.oauth.completeAuth(
      provider: 'google',
      state: state,
      code: code,
    );
  } catch (_) {
    // Swallow — the UI's auth gate will render the sign-in screen
    // again if this failed, and the user can retry cleanly.
  }
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spod Demo',
      debugShowCheckedModeBanner: false,
      theme: buildDemoTheme(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    spod.userAuth.events.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!spod.userAuth.isSignedIn) {
      return SignInScreen(onSignedIn: () => setState(() {}));
    }
    return PostsScreen(
      onSignOut: () async {
        await spod.userAuth.signOut();
        if (mounted) setState(() {});
      },
    );
  }
}
