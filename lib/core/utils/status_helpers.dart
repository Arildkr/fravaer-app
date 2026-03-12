import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/tables.dart';
import '../theme/app_theme.dart';

/// Hjelpefunksjoner for statusvisning.
extension AttendanceStatusExtension on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.ukjent:
        return 'Ikke møtt';
      case AttendanceStatus.tilStede:
        return 'Innsjekket';
      case AttendanceStatus.fravaer:
        return 'Fravær';
      case AttendanceStatus.forseinka:
        return 'Forsinket';
      case AttendanceStatus.utsjekket:
        return 'Utsjekket';
    }
  }

  String labelOf(AppLocalizations l10n) {
    switch (this) {
      case AttendanceStatus.ukjent:
        return l10n.statusUnknown;
      case AttendanceStatus.tilStede:
        return l10n.statusPresent;
      case AttendanceStatus.fravaer:
        return l10n.statusAbsent;
      case AttendanceStatus.forseinka:
        return l10n.statusLate;
      case AttendanceStatus.utsjekket:
        return l10n.statusCheckedOut;
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
      case AttendanceStatus.utsjekket:
        return '\uD83C\uDFE0'; // 🏠
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
      case AttendanceStatus.utsjekket:
        return AppTheme.statusPlanlagtBorte;
    }
  }

  /// Tap-syklus: ikke møtt → innsjekket → utsjekket → ikke møtt
  AttendanceStatus get nextStatus {
    switch (this) {
      case AttendanceStatus.ukjent:
        return AttendanceStatus.tilStede;
      case AttendanceStatus.tilStede:
        return AttendanceStatus.utsjekket;
      case AttendanceStatus.utsjekket:
        return AttendanceStatus.ukjent;
      case AttendanceStatus.fravaer:
        return AttendanceStatus.ukjent;
      case AttendanceStatus.forseinka:
        return AttendanceStatus.tilStede;
    }
  }
}
