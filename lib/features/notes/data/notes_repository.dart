import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';

class NotesRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  NotesRepository(this._db);

  /// Hent aktive merknader for en elev (ikke utløpte).
  Stream<List<ElevMerknaderData>> watchActiveNotes(String elevId) {
    final now = DateTime.now();
    return (_db.select(_db.elevMerknader)
          ..where((n) =>
              n.elevId.equals(elevId) &
              (n.erPermanent.equals(true) |
                  n.utlopsDato.isBiggerOrEqualValue(now)))
          ..orderBy([(n) => OrderingTerm.desc(n.opprettetDato)]))
        .watch();
  }

  /// Opprett en merknad.
  Future<void> createNote({
    required String elevId,
    required String tekst,
    bool erPermanent = false,
    DateTime? utlopsDato,
  }) async {
    await _db.into(_db.elevMerknader).insert(ElevMerknaderCompanion.insert(
      id: _uuid.v4(),
      elevId: elevId,
      tekst: tekst,
      erPermanent: Value(erPermanent),
      utlopsDato: Value(erPermanent ? null : utlopsDato),
    ));
  }

  /// Slett en merknad.
  Future<void> deleteNote(String noteId) async {
    await (_db.delete(_db.elevMerknader)..where((n) => n.id.equals(noteId)))
        .go();
  }
}
