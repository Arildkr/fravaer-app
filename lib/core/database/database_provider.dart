import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'database.dart';

const _keyName = 'fravaer_db_encryption_key';

/// Genererer en tilfeldig 32-tegns hex-nøkkel.
String _generateKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Henter eller oppretter krypteringsnøkkel fra sikker lagring.
/// Må kalles før databasen brukes.
final encryptionKeyProvider = FutureProvider<String>((ref) async {
  const storage = FlutterSecureStorage();
  var key = await storage.read(key: _keyName);
  if (key == null) {
    key = _generateKey();
    await storage.write(key: _keyName, value: key);
  }
  return key;
});

/// Singleton database-provider. Krever at encryptionKey er lastet.
final databaseProvider = Provider<AppDatabase>((ref) {
  final keyAsync = ref.watch(encryptionKeyProvider);
  final key = keyAsync.valueOrNull;
  if (key == null) {
    throw StateError('Krypteringsnøkkel ikke lastet ennå');
  }
  final db = AppDatabase(encryptionKey: key);
  ref.onDispose(() => db.close());
  return db;
});
