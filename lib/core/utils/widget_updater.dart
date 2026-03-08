import 'package:home_widget/home_widget.dart';

/// Oppdaterer Android home screen widget med aktuell status.
class WidgetUpdater {
  static const _appWidgetProvider =
      'no.fravaer.fravaer_app.HomeWidgetProvider';

  /// Oppdater widget med aktiv økt-info.
  static Future<void> updateActiveSession({
    required String gruppeNavn,
    required int tilStede,
    required int totalt,
  }) async {
    await HomeWidget.saveWidgetData('widget_status', gruppeNavn);
    await HomeWidget.saveWidgetData(
        'widget_count', '$tilStede / $totalt til stede');
    await HomeWidget.updateWidget(
      androidName: _appWidgetProvider,
    );
  }

  /// Fjern aktiv økt fra widget.
  static Future<void> clearSession() async {
    await HomeWidget.saveWidgetData('widget_status', 'Ingen aktiv økt');
    await HomeWidget.saveWidgetData('widget_count', '');
    await HomeWidget.updateWidget(
      androidName: _appWidgetProvider,
    );
  }
}
