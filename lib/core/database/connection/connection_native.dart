import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';

QueryExecutor openConnection(String encryptionKey) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'fravaer.db'));

    // Must override in both main isolate and background isolate
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);

    return NativeDatabase.createInBackground(
      file,
      isolateSetup: () {
        open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
      },
      setup: (database) {
        database.execute("PRAGMA key = '$encryptionKey'");
        database.execute('PRAGMA foreign_keys = ON');
      },
    );
  });
}
