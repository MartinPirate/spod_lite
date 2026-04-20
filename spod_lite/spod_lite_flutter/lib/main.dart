import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:spod_lite_client/spod_lite_client.dart';

import 'auth/admin_auth_key_provider.dart';
import 'auth/auth_gate.dart';
import 'auth/auth_state.dart';
import 'theme.dart';

late final Client client;
late final AuthState authState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final serverUrl = await getServerUrl();
  final keys = AdminAuthKeyProvider();
  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authKeyProvider = keys;
  authState = AuthState(client, keys);
  runApp(const SpodLiteApp());
}

class SpodLiteApp extends StatelessWidget {
  const SpodLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serverpod Lite',
      debugShowCheckedModeBanner: false,
      theme: buildDarkTheme(),
      home: AuthGate(state: authState),
    );
  }
}
