import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';

class GroupRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  GroupRepository(this._db);

  /// Hent alle aktive (ikke-arkiverte) grupper for en lærer.
  Stream<List<GrupperData>> watchActiveGroups(String laererId) {
    return (_db.select(_db.grupper)
          ..where((g) => g.laererId.equals(laererId) & g.arkivert.equals(false))
          ..orderBy([(g) => OrderingTerm.asc(g.navn)]))
        .watch();
  }

  /// Hent alle arkiverte grupper for en lærer.
  Stream<List<GrupperData>> watchArchivedGroups(String laererId) {
    return (_db.select(_db.grupper)
          ..where((g) => g.laererId.equals(laererId) & g.arkivert.equals(true))
          ..orderBy([(g) => OrderingTerm.asc(g.navn)]))
        .watch();
  }

  /// Opprett en ny gruppe.
  Future<GrupperData> createGroup({
    required String navn,
    required String laererId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.grupper).insert(GrupperCompanion.insert(
      id: id,
      navn: navn,
      type: GroupType.klasse, // Standard, brukes ikke i UI
      laererId: laererId,
    ));
    return (_db.select(_db.grupper)..where((g) => g.id.equals(id))).getSingle();
  }

  /// Kopier en gruppe — ny gruppe med samme elever.
  Future<GrupperData> copyGroup({
    required String sourceGruppeId,
    required String nyttNavn,
    required String laererId,
  }) async {
    final newGroup = await createGroup(navn: nyttNavn, laererId: laererId);

    // Kopier alle medlemskap
    final members = await (_db.select(_db.medlemskap)
          ..where((m) => m.gruppeId.equals(sourceGruppeId)))
        .get();

    for (final member in members) {
      await _db.into(_db.medlemskap).insert(MedlemskapCompanion.insert(
        id: _uuid.v4(),
        elevId: member.elevId,
        gruppeId: newGroup.id,
      ));
    }

    return newGroup;
  }

  /// Del en gruppe — opprett ny gruppe med utvalgte elever.
  Future<GrupperData> splitGroup({
    required String sourceGruppeId,
    required String nyttNavn,
    required String laererId,
    required List<String> elevIder,
  }) async {
    final newGroup = await createGroup(navn: nyttNavn, laererId: laererId);

    for (final elevId in elevIder) {
      await _db.into(_db.medlemskap).insert(MedlemskapCompanion.insert(
        id: _uuid.v4(),
        elevId: elevId,
        gruppeId: newGroup.id,
      ));
    }

    return newGroup;
  }

  /// Arkiver en gruppe (soft-delete). Elevdata bevares.
  Future<void> archiveGroup(String gruppeId) async {
    await (_db.update(_db.grupper)..where((g) => g.id.equals(gruppeId)))
        .write(const GrupperCompanion(arkivert: Value(true)));
  }

  /// Gjenopprett en arkivert gruppe.
  Future<void> restoreGroup(String gruppeId) async {
    await (_db.update(_db.grupper)..where((g) => g.id.equals(gruppeId)))
        .write(const GrupperCompanion(arkivert: Value(false)));
  }

  /// Gi nytt navn til en gruppe.
  Future<void> renameGroup(String gruppeId, String nyttNavn) async {
    await (_db.update(_db.grupper)..where((g) => g.id.equals(gruppeId)))
        .write(GrupperCompanion(navn: Value(nyttNavn)));
  }

  /// Gi nytt navn til en elev.
  Future<void> renameStudent(String elevId, String nyttNavn) async {
    await (_db.update(_db.elever)..where((e) => e.id.equals(elevId)))
        .write(EleverCompanion(navn: Value(nyttNavn)));
  }

  /// Hent alle elever i en gruppe via medlemskap.
  Stream<List<EleverData>> watchGroupMembers(String gruppeId) {
    final query = _db.select(_db.elever).join([
      innerJoin(
        _db.medlemskap,
        _db.medlemskap.elevId.equalsExp(_db.elever.id),
      ),
    ])
      ..where(_db.medlemskap.gruppeId.equals(gruppeId))
      ..orderBy([OrderingTerm.asc(_db.elever.navn)]);

    return query.watch().map(
        (rows) => rows.map((row) => row.readTable(_db.elever)).toList());
  }

  /// Hent alle elever i en gruppe (ikke-stream, for engangsbruk).
  Future<List<EleverData>> getGroupMembers(String gruppeId) async {
    final query = _db.select(_db.elever).join([
      innerJoin(
        _db.medlemskap,
        _db.medlemskap.elevId.equalsExp(_db.elever.id),
      ),
    ])
      ..where(_db.medlemskap.gruppeId.equals(gruppeId))
      ..orderBy([OrderingTerm.asc(_db.elever.navn)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(_db.elever)).toList();
  }

  /// Sjekk om en elev med dette navnet allerede finnes i gruppen.
  Future<bool> hasStudentWithName(String elevNavn, String gruppeId) async {
    final members = await getGroupMembers(gruppeId);
    return members.any((e) => e.navn == elevNavn);
  }

  /// Legg til en elev i en gruppe. Blokkerer duplikatnavn.
  Future<void> addStudentToGroup({
    required String elevNavn,
    required String gruppeId,
    String? elevId,
  }) async {
    // Blokker duplikatnavn i samme gruppe
    final existingMembers = await getGroupMembers(gruppeId);
    if (existingMembers.any((e) => e.navn == elevNavn)) return;

    final studentId = _uuid.v4();
    await _db.into(_db.elever).insert(EleverCompanion.insert(
      id: studentId,
      navn: elevNavn,
      elevId: Value(elevId),
    ));

    await _db.into(_db.medlemskap).insert(MedlemskapCompanion.insert(
      id: _uuid.v4(),
      elevId: studentId,
      gruppeId: gruppeId,
    ));
  }

  /// Fjern elev fra gruppe (sletter kun medlemskap, ikke eleven).
  Future<void> removeStudentFromGroup({
    required String elevId,
    required String gruppeId,
  }) async {
    await (_db.delete(_db.medlemskap)
          ..where(
              (m) => m.elevId.equals(elevId) & m.gruppeId.equals(gruppeId)))
        .go();
  }

  /// Importer elever fra CSV-tekst (én linje per elev).
  Future<int> importStudentsFromText({
    required String text,
    required String gruppeId,
  }) async {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    int imported = 0;
    for (final line in lines) {
      final parts = line.split(RegExp(r'[;,\t]'));
      final navn = parts[0].trim();
      final id = parts.length > 1 ? parts[1].trim() : null;

      if (navn.isNotEmpty) {
        await addStudentToGroup(
          elevNavn: navn,
          gruppeId: gruppeId,
          elevId: id,
        );
        imported++;
      }
    }
    return imported;
  }
}
