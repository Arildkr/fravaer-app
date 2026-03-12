import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/database/tables.dart';
import '../../attendance/data/attendance_repository.dart';

/// Genererer PDF-rapport for en fraværsøkt.
class PdfReportGenerator {
  static Future<Uint8List> generate({
    required String gruppeNavn,
    String? sessionNavn,
    required DateTime dato,
    required List<AttendanceRecord> records,
  }) async {
    final pdf = pw.Document();
    final datoStr = DateFormat('dd.MM.yyyy HH:mm').format(dato);

    final tilStede = records
        .where((r) => r.post.status == AttendanceStatus.tilStede)
        .toList();
    final fravaer = records
        .where((r) => r.post.status == AttendanceStatus.fravaer)
        .toList();
    final forsinket = records
        .where((r) => r.post.status == AttendanceStatus.forseinka)
        .toList();
    final utsjekket = records
        .where((r) => r.post.status == AttendanceStatus.utsjekket)
        .toList();
    final ukjent = records
        .where((r) => r.post.status == AttendanceStatus.ukjent)
        .toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Fraværsrapport',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Gruppe: $gruppeNavn',
                style: const pw.TextStyle(fontSize: 14)),
            if (sessionNavn != null && sessionNavn.isNotEmpty)
              pw.Text('Økt: $sessionNavn',
                  style: const pw.TextStyle(fontSize: 14)),
            pw.Text('Dato: $datoStr',
                style: const pw.TextStyle(fontSize: 14)),
            pw.Divider(),
          ],
        ),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Alle med',
                style: pw.TextStyle(
                    fontSize: 10, color: PdfColor.fromHex('#888888'))),
            pw.Text('Side ${context.pageNumber} av ${context.pagesCount}',
                style: pw.TextStyle(
                    fontSize: 10, color: PdfColor.fromHex('#888888'))),
          ],
        ),
        build: (context) => [
          // Oppsummering
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#E3F2FD'),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _summaryItem('Innsjekket', tilStede.length, '#4CAF50'),
                _summaryItem('Utsjekket', utsjekket.length, '#2196F3'),
                _summaryItem('Fravær', fravaer.length, '#F44336'),
                _summaryItem('Forsinket', forsinket.length, '#FF9800'),
                _summaryItem('Ukjent', ukjent.length, '#9E9E9E'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Elevtabell
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromHex('#DDDDDD')),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#1565C0')),
                children: [
                  _headerCell('Elev'),
                  _headerCell('Status'),
                  _headerCell('Merknad'),
                ],
              ),
              // Data
              ...records.map((r) => pw.TableRow(
                    children: [
                      _dataCell(r.elev.navn),
                      _statusCell(r.post.status, r.post.forsinkelsesMinutter),
                      _dataCell(r.post.merknad ?? ''),
                    ],
                  )),
            ],
          ),

          pw.SizedBox(height: 16),
          pw.Text(
            'Totalt: ${records.length} deltakere — '
            '${tilStede.length} innsjekket, ${utsjekket.length} utsjekket, '
            '${fravaer.length} fravær, ${forsinket.length} forsinket, '
            '${ukjent.length} ikke registrert',
            style: const pw.TextStyle(fontSize: 11),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _summaryItem(String label, int count, String hex) {
    return pw.Column(
      children: [
        pw.Text(count.toString(),
            style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex(hex))),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  static pw.Widget _headerCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white)),
    );
  }

  static pw.Widget _dataCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }

  static pw.Widget _statusCell(AttendanceStatus status, int? minutter) {
    final String text;
    switch (status) {
      case AttendanceStatus.tilStede:
        text = 'Til stede';
      case AttendanceStatus.fravaer:
        text = 'Fravær';
      case AttendanceStatus.forseinka:
        text = 'Forsinket${minutter != null ? ' ($minutter min)' : ''}';
      case AttendanceStatus.utsjekket:
        text = 'Utsjekket';
      case AttendanceStatus.ukjent:
        text = 'Ikke registrert';
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
    );
  }
}
