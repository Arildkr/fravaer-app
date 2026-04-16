import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

QueryExecutor openConnection(String encryptionKey) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fravaer.db'));

    return NativeDatabase.createInBackground(
      file,
      isolateSetup: () {},
      setup: (database) {
        // SQLite3MultipleCiphers med SQLCipher 4-kompatibilitet.
        // cipher='sqlcipher' + legacy=4 matcher SQLCipher 4.x standardinnstillinger,
        // slik at eksisterende krypterte databaser åpnes uten endring.
        database.execute("pragma cipher = 'sqlcipher'");
        database.execute('pragma legacy = 4');
        database.execute("PRAGMA key = \"x'$encryptionKey'\"");
        database.execute('PRAGMA foreign_keys = ON');
      },
    );
  });
}
