import 'dart:convert';

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
      qualifiedAndroidName: _appWidgetProvider,
    );
  }

  /// Fjern aktiv økt fra widget.
  static Future<void> clearSession() async {
    await HomeWidget.saveWidgetData('widget_status', '');
    await HomeWidget.saveWidgetData('widget_count', '');
    await HomeWidget.updateWidget(
      qualifiedAndroidName: _appWidgetProvider,
    );
  }

  /// Skriv tilgjengelige grupper til SharedPreferences slik at
  /// WidgetConfigActivity kan lese dem uten å ha tilgang til databasen.
  static Future<void> saveGroups(
      List<({String id, String name})> groups) async {
    final json = jsonEncode(
        groups.map((g) => {'id': g.id, 'name': g.name}).toList());
    await HomeWidget.saveWidgetData('available_groups', json);
  }
}
