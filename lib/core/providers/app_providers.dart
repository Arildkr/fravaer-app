import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database_provider.dart';
import '../../features/groups/data/group_repository.dart';
import '../../features/attendance/data/attendance_repository.dart';
import '../../features/reports/data/report_repository.dart';
import '../../features/subscription/data/subscription_service.dart';

/// Repository providers

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(ref.watch(databaseProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository(ref.watch(databaseProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(ref.watch(databaseProvider));
});

/// Aktiv lærer-ID. I V1 er dette en enkel singleton.
/// I fremtiden kan dette utvides med Firebase Auth.
final activeLaererIdProvider = StateProvider<String?>((ref) => null);

/// Aktiv økt-ID for registrering.
final activeSessionIdProvider = StateProvider<String?>((ref) => null);

/// Subscription service — settes av AppShell etter initialisering.
final subscriptionServiceProvider = StateProvider<SubscriptionService?>((ref) => null);

/// Valgt app-språk. Null = følg systemspråket.
final localeProvider = StateProvider<Locale?>((ref) => null);
