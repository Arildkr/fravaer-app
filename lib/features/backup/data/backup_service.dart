import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Google Drive backup-tjeneste.
/// Lagrer/gjenoppretter kryptert database til appDataFolder.
class BackupService {
  static const _backupFileName = 'allemed_backup.db';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  GoogleSignInAccount? _currentUser;

  /// Sjekk om bruker er logget inn.
  bool get isSignedIn => _currentUser != null;

  /// Prøv stille innlogging (ingen dialog). Returnerer true hvis allerede logget inn.
  Future<bool> trySignInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      return _currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Logg inn med Google (viser dialog).
  Future<bool> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      return _currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Logg ut.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  /// Last opp backup av databasefilen til Google Drive appDataFolder.
  Future<void> uploadBackup(String dbPath) async {
    final client = await _getAuthClient();
    if (client == null) throw Exception('Ikke logget inn');

    final driveApi = drive.DriveApi(client);

    // Sjekk om backup allerede finnes
    final existing = await _findBackupFile(driveApi);

    final dbFile = File(dbPath);
    final media = drive.Media(dbFile.openRead(), await dbFile.length());

    if (existing != null) {
      // Oppdater eksisterende fil
      await driveApi.files.update(
        drive.File()..name = _backupFileName,
        existing.id!,
        uploadMedia: media,
      );
    } else {
      // Opprett ny fil
      final driveFile = drive.File()
        ..name = _backupFileName
        ..parents = ['appDataFolder'];

      await driveApi.files.create(
        driveFile,
        uploadMedia: media,
      );
    }
  }

  /// Last ned backup fra Google Drive og returner lokal filsti.
  Future<String?> downloadBackup() async {
    final client = await _getAuthClient();
    if (client == null) throw Exception('Ikke logget inn');

    final driveApi = drive.DriveApi(client);
    final existing = await _findBackupFile(driveApi);

    if (existing == null) return null;

    final response = await driveApi.files.get(
      existing.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final dir = await getTemporaryDirectory();
    final localFile = File('${dir.path}/allemed_restore.db');
    final sink = localFile.openWrite();

    await for (final chunk in response.stream) {
      sink.add(chunk);
    }
    await sink.close();

    return localFile.path;
  }

  /// Sjekk om det finnes en backup på Drive.
  Future<DateTime?> getLastBackupDate() async {
    final client = await _getAuthClient();
    if (client == null) return null;

    final driveApi = drive.DriveApi(client);
    final existing = await _findBackupFile(driveApi);

    return existing?.modifiedTime;
  }

  Future<drive.File?> _findBackupFile(drive.DriveApi api) async {
    final result = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName'",
      $fields: 'files(id, name, modifiedTime)',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first;
    }
    return null;
  }

  Future<http.Client?> _getAuthClient() async {
    _currentUser ??= await _googleSignIn.signInSilently();
    if (_currentUser == null) return null;

    final headers = await _currentUser!.authHeaders;
    return _GoogleAuthClient(headers);
  }
}

/// HTTP-klient som legger til auth-headers.
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}
