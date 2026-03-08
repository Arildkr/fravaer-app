import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';

/// Singleton database-provider.
/// Krypteringsnøkkel bør i fremtiden hentes fra sikker lagring (FlutterSecureStorage).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase(encryptionKey: 'fravaer_app_v1_key');
  ref.onDispose(() => db.close());
  return db;
});
