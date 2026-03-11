import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

/// Resultat fra filparsing — liste med navn klare for import.
class ImportPreview {
  final List<String> names;
  final bool hadHeader;
  final String sourceFileName;

  const ImportPreview({
    required this.names,
    required this.hadHeader,
    required this.sourceFileName,
  });
}

/// Tjeneste for å lese elevnavn fra xlsx, xls og csv-filer.
class FileImportService {
  /// Les og pars en fil. Returnerer forhåndsvisning med detekterte navn.
  static Future<ImportPreview> parseFile(File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last.toLowerCase();
    final bytes = await file.readAsBytes();

    if (fileName.endsWith('.csv') || fileName.endsWith('.txt')) {
      return _parseCsv(bytes, fileName);
    } else if (fileName.endsWith('.xlsx') ||
        fileName.endsWith('.xls') ||
        fileName.endsWith('.ods')) {
      return _parseSpreadsheet(bytes, fileName);
    } else {
      // Ukjent filtype (f.eks. fra Google Drive) — prøv regneark, så CSV.
      try {
        return _parseSpreadsheet(bytes, fileName);
      } catch (_) {
        return _parseCsv(bytes, fileName);
      }
    }
  }

  static ImportPreview _parseCsv(Uint8List bytes, String fileName) {
    // Prøv UTF-8 først. Hvis det feiler (replacement characters), bruk Latin-1.
    String content = utf8.decode(bytes, allowMalformed: true);
    if (content.contains('\uFFFD')) {
      content = latin1.decode(bytes);
    }
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
      allowInvalid: true,
    ).convert(content);

    return _processRows(
      rows.map((r) => r.map((c) => c.toString()).toList()).toList(),
      fileName,
    );
  }

  static ImportPreview _parseSpreadsheet(Uint8List bytes, String fileName) {
    final decoder = SpreadsheetDecoder.decodeBytes(bytes);
    final firstSheet = decoder.tables.values.first;

    final rows = firstSheet.rows
        .map((r) => r.map((c) => c?.toString() ?? '').toList())
        .toList();

    return _processRows(rows, fileName);
  }

  /// Prosesser rader: detekter header, håndter 1-2 kolonner, bygg navnliste.
  static ImportPreview _processRows(
      List<List<String>> rows, String fileName) {
    if (rows.isEmpty) {
      return ImportPreview(names: [], hadHeader: false, sourceFileName: fileName);
    }

    // Fjern helt tomme rader
    final nonEmpty =
        rows.where((r) => r.any((c) => c.trim().isNotEmpty)).toList();

    if (nonEmpty.isEmpty) {
      return ImportPreview(names: [], hadHeader: false, sourceFileName: fileName);
    }

    // Sjekk om første rad er en header
    final hadHeader = _looksLikeHeader(nonEmpty.first);
    final dataRows = hadHeader ? nonEmpty.skip(1).toList() : nonEmpty;

    // Finn antall brukte kolonner (maks i første datarader)
    final maxCols = dataRows.isEmpty
        ? 1
        : dataRows
            .take(5)
            .map((r) => r.where((c) => c.trim().isNotEmpty).length)
            .reduce((a, b) => a > b ? a : b);

    final names = <String>[];
    for (final row in dataRows) {
      if (row.isEmpty) continue;

      String name;
      if (maxCols >= 2 && row.length >= 2) {
        // To kolonner: fornavn + etternavn
        final col1 = row[0].trim();
        final col2 = row[1].trim();
        if (col1.isNotEmpty && col2.isNotEmpty) {
          name = '$col1 $col2';
        } else if (col1.isNotEmpty) {
          name = col1;
        } else {
          continue;
        }
      } else {
        // Én kolonne: fullt navn
        name = row[0].trim();
      }

      if (name.isNotEmpty) {
        names.add(name);
      }
    }

    return ImportPreview(
      names: names,
      hadHeader: hadHeader,
      sourceFileName: fileName,
    );
  }

  /// Sjekk om en rad ser ut som en overskriftsrad.
  static bool _looksLikeHeader(List<String> row) {
    if (row.isEmpty) return false;
    final first = row[0].trim().toLowerCase();

    const headerWords = [
      'navn',
      'name',
      'fornavn',
      'first name',
      'firstname',
      'etternavn',
      'last name',
      'lastname',
      'elev',
      'student',
      'nr',
      'nummer',
      '#',
    ];

    return headerWords.any((w) => first.contains(w));
  }
}
