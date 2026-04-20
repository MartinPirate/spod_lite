import 'package:serverpod/serverpod.dart';
import '../widgets/landing_page.dart';

class RootRoute extends WidgetRoute {
  @override
  Future<TemplateWidget> build(Session session, Request request) async {
    return LandingPageWidget.build(session);
  }
}
