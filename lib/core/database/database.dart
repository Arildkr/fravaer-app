import 'package:drift/drift.dart';

import 'tables.dart';
import 'connection/connection.dart' as impl;

part 'database.g.dart';

@DriftDatabase(tables: [
  Laerere,
  Elever,
  Grupper,
  Medlemskap,
  FravaersOkter,
  FravaersPoster,
  ElevMerknader,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.e);

  factory AppDatabase({required String encryptionKey}) {
    return AppDatabase._internal(
      impl.openConnection(encryptionKey),
    );
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // v2: legg til valgfritt navn på økt
          await m.addColumn(fravaersOkter, fravaersOkter.navn);
        }
      },
      beforeOpen: (details) async {
        // Kjør alltid — verifiser integritet ved oppstart
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
