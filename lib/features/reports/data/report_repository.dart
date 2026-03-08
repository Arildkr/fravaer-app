import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';
import '../../attendance/data/attendance_repository.dart';
import 'pdf_report_generator.dart';

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

    final records = await _getSessionRecords(oktId);

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
        buffer.writeln(
            '  ${r.elev.navn}${merknad.isNotEmpty ? ' - $merknad' : ''}');
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

  /// Generer PDF-rapport for en økt.
  Future<Uint8List> generatePdfReport(String oktId) async {
    final session = await (_db.select(_db.fravaersOkter)
          ..where((s) => s.id.equals(oktId)))
        .getSingle();

    final gruppe = await (_db.select(_db.grupper)
          ..where((g) => g.id.equals(session.gruppeId)))
        .getSingle();

    final records = await _getSessionRecords(oktId);

    return PdfReportGenerator.generate(
      gruppeNavn: gruppe.navn,
      dato: session.dato,
      records: records,
    );
  }

  /// Generer CSV-semesterrapport for en gruppe.
  /// Viser alle økter i perioden med én rad per elev.
  Future<String> generateSemesterCsv({
    required String gruppeId,
    required DateTime fraDato,
    required DateTime tilDato,
  }) async {
    final dateFormat = DateFormat('dd.MM.yyyy');

    // Hent alle økter i perioden
    final sessions = await (_db.select(_db.fravaersOkter)
          ..where((s) =>
              s.gruppeId.equals(gruppeId) &
              s.dato.isBiggerOrEqualValue(fraDato) &
              s.dato.isSmallerOrEqualValue(tilDato))
          ..orderBy([(s) => OrderingTerm.asc(s.dato)]))
        .get();

    if (sessions.isEmpty) return '';

    // Hent alle elever i gruppen
    final membersQuery = _db.select(_db.elever).join([
      innerJoin(
        _db.medlemskap,
        _db.medlemskap.elevId.equalsExp(_db.elever.id),
      ),
    ])
      ..where(_db.medlemskap.gruppeId.equals(gruppeId))
      ..orderBy([OrderingTerm.asc(_db.elever.navn)]);

    final memberRows = await membersQuery.get();
    final elever = memberRows.map((r) => r.readTable(_db.elever)).toList();

    // Hent alle fraværsposter for disse øktene
    final sessionIds = sessions.map((s) => s.id).toList();
    final poster = await (_db.select(_db.fravaersPoster)
          ..where((p) => p.oktId.isIn(sessionIds)))
        .get();

    // Bygg oppslagstabell: elevId → oktId → post
    final Map<String, Map<String, FravaersPosterData>> lookup = {};
    for (final post in poster) {
      lookup.putIfAbsent(post.elevId, () => {});
      lookup[post.elevId]![post.oktId] = post;
    }

    // Bygg CSV
    final rows = <List<String>>[];

    // Header
    final header = ['Elev'];
    for (final s in sessions) {
      header.add(dateFormat.format(s.dato));
    }
    header.addAll(['Totalt fravær', 'Totalt forsinket']);
    rows.add(header);

    // Data
    for (final elev in elever) {
      final row = <String>[elev.navn];
      int totalFravaer = 0;
      int totalForsinket = 0;

      for (final session in sessions) {
        final post = lookup[elev.id]?[session.id];
        if (post == null) {
          row.add('-');
        } else {
          switch (post.status) {
            case AttendanceStatus.tilStede:
              row.add('T');
            case AttendanceStatus.fravaer:
              row.add('F');
              totalFravaer++;
            case AttendanceStatus.forseinka:
              final min = post.forsinkelsesMinutter ?? 0;
              row.add('S$min');
              totalForsinket++;
            case AttendanceStatus.planlagtBorte:
              row.add('P');
            case AttendanceStatus.ukjent:
              row.add('?');
          }
        }
      }

      row.add(totalFravaer.toString());
      row.add(totalForsinket.toString());
      rows.add(row);
    }

    return const ListToCsvConverter(fieldDelimiter: ';').convert(rows);
  }

  Future<List<AttendanceRecord>> _getSessionRecords(String oktId) async {
    final query = _db.select(_db.fravaersPoster).join([
      innerJoin(
        _db.elever,
        _db.elever.id.equalsExp(_db.fravaersPoster.elevId),
      ),
    ])
      ..where(_db.fravaersPoster.oktId.equals(oktId))
      ..orderBy([OrderingTerm.asc(_db.elever.navn)]);

    final rows = await query.get();
    return rows.map((row) {
      final post = row.readTable(_db.fravaersPoster);
      final elev = row.readTable(_db.elever);
      return AttendanceRecord(post: post, elev: elev);
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
