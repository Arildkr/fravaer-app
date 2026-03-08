import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';

class AttendanceRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  AttendanceRepository(this._db);

  /// Opprett en ny fraværsøkt for en gruppe.
  Future<FravaersOkterData> createSession({
    required String gruppeId,
    required String laererId,
    required SessionType type,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.fravaersOkter).insert(FravaersOkterCompanion.insert(
      id: id,
      dato: now,
      type: type,
      gruppeId: gruppeId,
      laererId: laererId,
    ));

    // Opprett fraværsposter med status "ukjent" for alle elever i gruppen
    final members = await (_db.select(_db.medlemskap)
          ..where((m) => m.gruppeId.equals(gruppeId)))
        .get();

    for (final member in members) {
      await _db.into(_db.fravaersPoster).insert(FravaersPosterCompanion.insert(
        id: _uuid.v4(),
        elevId: member.elevId,
        oktId: id,
        status: AttendanceStatus.ukjent,
      ));
    }

    return (_db.select(_db.fravaersOkter)..where((s) => s.id.equals(id)))
        .getSingle();
  }

  /// Hent alle fraværsposter for en økt, med elevinfo.
  Stream<List<AttendanceRecord>> watchSessionRecords(String oktId) {
    final query = _db.select(_db.fravaersPoster).join([
      innerJoin(
        _db.elever,
        _db.elever.id.equalsExp(_db.fravaersPoster.elevId),
      ),
    ])
      ..where(_db.fravaersPoster.oktId.equals(oktId))
      ..orderBy([OrderingTerm.asc(_db.elever.navn)]);

    return query.watch().map((rows) => rows.map((row) {
          final post = row.readTable(_db.fravaersPoster);
          final elev = row.readTable(_db.elever);
          return AttendanceRecord(post: post, elev: elev);
        }).toList());
  }

  /// Oppdater status for en elev i en økt.
  Future<void> updateStatus({
    required String postId,
    required AttendanceStatus status,
    int? forsinkelsesMinutter,
    String? merknad,
  }) async {
    await (_db.update(_db.fravaersPoster)..where((p) => p.id.equals(postId)))
        .write(FravaersPosterCompanion(
      status: Value(status),
      forsinkelsesMinutter: Value(forsinkelsesMinutter),
      merknad: Value(merknad),
      tidspunkt: Value(DateTime.now()),
    ));
  }

  /// Avslutt en økt.
  Future<void> endSession(String oktId) async {
    await (_db.update(_db.fravaersOkter)..where((s) => s.id.equals(oktId)))
        .write(const FravaersOkterCompanion(avsluttet: Value(true)));
  }

  /// Hent aktive (ikke avsluttede) økter for en lærer.
  Stream<List<FravaersOkterData>> watchActiveSessions(String laererId) {
    return (_db.select(_db.fravaersOkter)
          ..where((s) =>
              s.laererId.equals(laererId) & s.avsluttet.equals(false))
          ..orderBy([(s) => OrderingTerm.desc(s.dato)]))
        .watch();
  }

  /// Angre siste registrering (sett tilbake til ukjent).
  Future<void> undoLastRegistration(String oktId) async {
    final posts = await (_db.select(_db.fravaersPoster)
          ..where((p) =>
              p.oktId.equals(oktId) &
              p.status.equals(AttendanceStatus.ukjent.index).not())
          ..orderBy([(p) => OrderingTerm.desc(p.tidspunkt)])
          ..limit(1))
        .get();

    if (posts.isNotEmpty) {
      await updateStatus(
        postId: posts.first.id,
        status: AttendanceStatus.ukjent,
      );
    }
  }
}

/// Kombinert data-objekt for visning.
class AttendanceRecord {
  final FravaersPosterData post;
  final EleverData elev;

  const AttendanceRecord({required this.post, required this.elev});
}
