import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'database.dart';

const _keyName = 'fravaer_db_encryption_key';
const _dbFileName = 'fravaer.db';

/// Genererer en tilfeldig 32-tegns hex-nøkkel.
String _generateKey() {
  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Sletter databasefilen. Kalles ved nøkkelfeil for å unngå korrupt tilstand.
Future<void> _deleteDatabase() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, _dbFileName));
    if (await file.exists()) await file.delete();
  } catch (_) {}
}

/// Henter eller oppretter krypteringsnøkkel fra sikker lagring.
/// Ved feil (f.eks. etter reinstallasjon med Android Auto Backup) slettes
/// nøkkel og DB-fil slik at appen starter med ren tilstand.
final encryptionKeyProvider = FutureProvider<String>((ref) async {
  const storage = FlutterSecureStorage();

  String? key;
  try {
    key = await storage.read(key: _keyName);
  } catch (_) {
    // Keystore-nøkkelen er ugyldig — typisk etter reinstallasjon der
    // Auto Backup gjenoppretter krypterte SharedPrefs men ikke Keystore-nøkkelen.
    await storage.deleteAll();
    await _deleteDatabase();
  }

  if (key == null) {
    // Ny installasjon eller nøkkel ble slettet — slett evt. gjenopprettet DB-fil
    // (Auto Backup kan ha gjenopprettet en DB som ikke matcher den nye nøkkelen).
    await _deleteDatabase();
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
