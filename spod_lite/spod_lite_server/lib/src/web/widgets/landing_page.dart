import 'package:serverpod/serverpod.dart';
import '../../generated/protocol.dart';

class LandingPageWidget extends TemplateWidget {
  LandingPageWidget._({required Map<String, dynamic> values})
      : super(name: 'serverpod_lite_landing') {
    this.values = values;
  }

  static Future<LandingPageWidget> build(Session session) async {
    final hasAdmins = (await AdminUser.db.count(session)) > 0;
    final apiConfig = Serverpod.instance.config.apiServer;
    final apiUrl =
        '${apiConfig.publicScheme}://${apiConfig.publicHost}:${apiConfig.publicPort}/';

    return LandingPageWidget._(values: {
      'served': DateTime.now().toUtc().toIso8601String(),
      'runmode': Serverpod.instance.runMode,
      'version': '3.4.7',
      'dartVersion': '3.10+',
      'apiUrl': apiUrl,
      'dashboardUrl': '/app/',
      'adminState': hasAdmins ? 'Configured' : 'Not yet configured',
      'adminHint': hasAdmins
          ? 'Sign in from the dashboard to manage your data.'
          : 'Open the dashboard to create your first admin.',
      'shippedCount':
          'M1 · M2.1 dynamic collections · M2.2 rules · M2.3 users · realtime · files',
    });
  }
}

