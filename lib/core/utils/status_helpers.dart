import 'package:flutter/material.dart';

import '../database/tables.dart';
import '../theme/app_theme.dart';

/// Hjelpefunksjoner for statusvisning.
extension AttendanceStatusExtension on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.ukjent:
        return 'Ukjent';
      case AttendanceStatus.tilStede:
        return 'Til stede';
      case AttendanceStatus.fravaer:
        return 'Fravær';
      case AttendanceStatus.forseinka:
        return 'Forsinket';
      case AttendanceStatus.planlagtBorte:
        return 'Planlagt borte';
    }
  }

  String get symbol {
    switch (this) {
      case AttendanceStatus.ukjent:
        return '\u2B1C'; // ⬜
      case AttendanceStatus.tilStede:
        return '\u2705'; // ✅
      case AttendanceStatus.fravaer:
        return '\u274C'; // ❌
      case AttendanceStatus.forseinka:
        return '\uD83D\uDD50'; // 🕐
      case AttendanceStatus.planlagtBorte:
        return '\uD83D\uDCCB'; // 📋
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.ukjent:
        return AppTheme.statusUkjent;
      case AttendanceStatus.tilStede:
        return AppTheme.statusTilStede;
      case AttendanceStatus.fravaer:
        return AppTheme.statusFravaer;
      case AttendanceStatus.forseinka:
        return AppTheme.statusForseinka;
      case AttendanceStatus.planlagtBorte:
        return AppTheme.statusPlanlagtBorte;
    }
  }

  /// Neste status i syklusen ved trykk (for enkel toggle).
  AttendanceStatus get nextStatus {
    switch (this) {
      case AttendanceStatus.ukjent:
        return AttendanceStatus.tilStede;
      case AttendanceStatus.tilStede:
        return AttendanceStatus.fravaer;
      case AttendanceStatus.fravaer:
        return AttendanceStatus.forseinka;
      case AttendanceStatus.forseinka:
        return AttendanceStatus.planlagtBorte;
      case AttendanceStatus.planlagtBorte:
        return AttendanceStatus.ukjent;
    }
  }
}
