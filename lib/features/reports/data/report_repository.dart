import 'package:drift/drift.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';
import '../../attendance/data/attendance_repository.dart';

class ReportRepository {
  final AppDatabase _db;

  ReportRepository(this._db);

  /// Generer tekstrapport for en økt.
  Future<String> generateReport(String oktId) async {
    final session = await (_db.select(_db.fravaersOkter)
          ..where((s) => s.id.equals(oktId)))
        .getSingle();

    final gruppe = await (_db.select(_db.grupper)
          ..where((g) => g.id.equals(session.gruppeId)))
        .getSingle();

    final query = _db.select(_db.fravaersPoster).join([
      innerJoin(
        _db.elever,
        _db.elever.id.equalsExp(_db.fravaersPoster.elevId),
      ),
    ])
      ..where(_db.fravaersPoster.oktId.equals(oktId))
      ..orderBy([OrderingTerm.asc(_db.elever.navn)]);

    final rows = await query.get();
    final records = rows.map((row) {
      final post = row.readTable(_db.fravaersPoster);
      final elev = row.readTable(_db.elever);
      return AttendanceRecord(post: post, elev: elev);
    }).toList();

    final buffer = StringBuffer();
    final dato = _formatDate(session.dato);

    buffer.writeln('FRAVÆRSRAPPORT');
    buffer.writeln('Gruppe: ${gruppe.navn}');
    buffer.writeln('Dato: $dato');
    buffer.writeln('---');

    final fravaerende = records
        .where((r) => r.post.status == AttendanceStatus.fravaer)
        .toList();
    if (fravaerende.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('FRAVÆR:');
      for (final r in fravaerende) {
        buffer.writeln('  ${r.elev.navn}');
      }
    }

    final forsinkede = records
        .where((r) => r.post.status == AttendanceStatus.forseinka)
        .toList();
    if (forsinkede.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('FORSINKET:');
      for (final r in forsinkede) {
        final min = r.post.forsinkelsesMinutter ?? 0;
        buffer.writeln('  ${r.elev.navn} - $min min');
      }
    }

    final planlagt = records
        .where((r) => r.post.status == AttendanceStatus.planlagtBorte)
        .toList();
    if (planlagt.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('PLANLAGT FRAVÆR:');
      for (final r in planlagt) {
        final merknad = r.post.merknad ?? '';
        buffer.writeln('  ${r.elev.navn}${merknad.isNotEmpty ? ' - $merknad' : ''}');
      }
    }

    final ukjente = records
        .where((r) => r.post.status == AttendanceStatus.ukjent)
        .toList();
    if (ukjente.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('IKKE REGISTRERT:');
      for (final r in ukjente) {
        buffer.writeln('  ${r.elev.navn}');
      }
    }

    final tilStede = records
        .where((r) => r.post.status == AttendanceStatus.tilStede)
        .length;
    buffer.writeln('');
    buffer.writeln('---');
    buffer.writeln(
        'Oppsummering: $tilStede til stede, ${fravaerende.length} fravær, '
        '${forsinkede.length} forsinket, ${planlagt.length} planlagt borte, '
        '${ukjente.length} ikke registrert');
    buffer.writeln('Totalt: ${records.length} elever');

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
