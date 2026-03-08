import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Haptisk feedback for fraværsregistrering.
/// Bruker Flutter sin innebygde HapticFeedback som er web-safe.
class HapticService {
  /// Kort vibrasjon — til stede
  static Future<void> onPresent() async {
    if (!kIsWeb) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Dobbel vibrasjon — fravær
  static Future<void> onAbsent() async {
    if (!kIsWeb) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Lang vibrasjon — alle registrert
  static Future<void> onAllRegistered() async {
    if (!kIsWeb) {
      await HapticFeedback.heavyImpact();
    }
  }
}
