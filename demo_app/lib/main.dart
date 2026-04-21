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
  await spod.userAuth.restore();
  runApp(const DemoApp());
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
