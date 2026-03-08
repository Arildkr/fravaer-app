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

  factory AppDatabase({String? encryptionKey}) {
    return AppDatabase._internal(
      impl.openConnection(encryptionKey ?? 'default_dev_key'),
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Fremtidige migrasjoner legges her
      },
    );
  }
}
