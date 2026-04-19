import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/database/tables.dart';

/// Resultatet av å bli med i en delt økt.
class JoinedSessionResult {
  final String localSessionId;
  final String localGroupId;
  final String sessionName;
  final String groupName;
  final int studentCount;

  const JoinedSessionResult({
    required this.localSessionId,
    required this.localGroupId,
    required this.sessionName,
    required this.groupName,
    required this.studentCount,
  });
}

/// Tjeneste for sanntidsdeling av fraværsøkter via Firebase.
///
/// - Lokal SQLite er alltid primærlagring.
/// - Firestore brukes kun mens en økt er aktiv og deles.
/// - Skydata slettes automatisk når eier avslutter deling.
class SessionSharingService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AppDatabase _db;

  final Map<String, StreamSubscription<QuerySnapshot>> _listeners = {};

  static const _uuid = Uuid();
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  SessionSharingService({
    required AppDatabase db,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = db,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // ─── Autentisering ──────────────────────────────────────────────

  Future<String> ensureSignedIn() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
    return _auth.currentUser!.uid;
  }

  String? get currentUid => _auth.currentUser?.uid;

  // ─── Invitasjonskode ─────────────────────────────────────────────

  String _generateCode() {
    final rng = Random.secure();
    return List.generate(6, (_) => _alphabet[rng.nextInt(_alphabet.length)]).join();
  }

  // ─── Del en økt (eier) ───────────────────────────────────────────

  Future<String> shareSession({
    required FravaersOkterData session,
    required String groupName,
    required List<({String postId, String studentName, AttendanceStatus status, int? forsinkelsesMinutter, String? merknad})> records,
  }) async {
    final uid = await ensureSignedIn();
    final shareId = session.id;
    final code = _generateCode();

    final batch = _firestore.batch();

    final sessionRef = _firestore.collection('sharedSessions').doc(shareId);
    batch.set(sessionRef, {
      'groupName': groupName,
      'sessionName': session.navn,
      'ownerId': uid,
      'memberIds': [uid],
      'inviteCode': code,
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });

    final codeRef = _firestore.collection('sessionCodes').doc(code);
    batch.set(codeRef, {'shareId': shareId});

    await batch.commit();

    await Future.wait(records.map((r) => _firestore
        .collection('sharedSessions')
        .doc(shareId)
        .collection('records')
        .doc(r.postId)
        .set({
      'studentName': r.studentName,
      'status': r.status.index,
      'forsinkelsesMinutter': r.forsinkelsesMinutter,
      'merknad': r.merknad,
      'updatedAt': FieldValue.serverTimestamp(),
    })));

    await (_db.update(_db.fravaersOkter)..where((s) => s.id.equals(session.id)))
        .write(FravaersOkterCompanion(shareId: Value(shareId)));

    return code;
  }

  // ─── Bli med (medlærer) ──────────────────────────────────────────

  Future<Map<String, dynamic>?> lookupCode(String code) async {
    await ensureSignedIn();
    final codeDoc = await _firestore
        .collection('sessionCodes')
        .doc(code.toUpperCase().trim())
        .get();
    if (!codeDoc.exists) return null;

    final shareId = codeDoc.data()!['shareId'] as String;
    final sessionDoc =
        await _firestore.collection('sharedSessions').doc(shareId).get();
    if (!sessionDoc.exists) return null;

    final data = sessionDoc.data()!;
    if (data['isActive'] != true) return null;

    final records = await _firestore
        .collection('sharedSessions')
        .doc(shareId)
        .collection('records')
        .get();

    return {
      'shareId': shareId,
      'groupName': data['groupName'] as String,
      'sessionName': data['sessionName'],
      'studentCount': records.size,
    };
  }

  /// Kobler medlærer til en økt og lager permanent lokal gruppe.
  Future<JoinedSessionResult> joinSession({
    required String shareId,
    required String laererId,
  }) async {
    final uid = await ensureSignedIn();

    await _firestore.collection('sharedSessions').doc(shareId).update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });

    final sessionDoc =
        await _firestore.collection('sharedSessions').doc(shareId).get();
    final sessionData = sessionDoc.data()!;
    final groupName = sessionData['groupName'] as String;
    final sessionName = sessionData['sessionName'] as String?;

    final recordsSnap = await _firestore
        .collection('sharedSessions')
        .doc(shareId)
        .collection('records')
        .get();

    // Permanent lokal gruppe — medlærer beholder denne etter at deling slutter
    final localGroupId = _uuid.v4();
    await _db.into(_db.grupper).insert(GrupperCompanion.insert(
      id: localGroupId,
      navn: groupName,
      type: GroupType.klasse,
      laererId: laererId,
    ));

    final localSessionId = _uuid.v4();
    await _db.into(_db.fravaersOkter).insert(FravaersOkterCompanion.insert(
      id: localSessionId,
      navn: Value(sessionName),
      dato: DateTime.now(),
      type: SessionType.turregistrering,
      gruppeId: localGroupId,
      laererId: laererId,
      shareId: Value(shareId),
    ));

    // Map Firestore record-ID → lokal FravaersPost-ID (her: samme ID)
    for (final doc in recordsSnap.docs) {
      final data = doc.data();
      final studentName = data['studentName'] as String;

      final elevId = _uuid.v4();
      await _db.into(_db.elever).insert(EleverCompanion.insert(
        id: elevId,
        navn: studentName,
      ));
      await _db.into(_db.medlemskap).insert(MedlemskapCompanion.insert(
        id: _uuid.v4(),
        elevId: elevId,
        gruppeId: localGroupId,
      ));
      // Bruker Firestore doc.id som lokal post-ID for direkte mapping
      await _db.into(_db.fravaersPoster).insert(FravaersPosterCompanion.insert(
        id: doc.id,
        elevId: elevId,
        oktId: localSessionId,
        status: AttendanceStatus.values[data['status'] as int],
        forsinkelsesMinutter: Value(data['forsinkelsesMinutter'] as int?),
        merknad: Value(data['merknad'] as String?),
      ));
    }

    return JoinedSessionResult(
      localSessionId: localSessionId,
      localGroupId: localGroupId,
      sessionName: sessionName ?? groupName,
      groupName: groupName,
      studentCount: recordsSnap.size,
    );
  }

  // ─── Sanntidssynk ────────────────────────────────────────────────

  void startListening({required String shareId}) {
    if (_listeners.containsKey(shareId)) return;

    final sub = _firestore
        .collection('sharedSessions')
        .doc(shareId)
        .collection('records')
        .snapshots()
        .listen((snap) async {
      for (final change in snap.docChanges) {
        if (change.type == DocumentChangeType.modified ||
            change.type == DocumentChangeType.added) {
          final data = change.doc.data()!;
          final postId = change.doc.id; // er lik lokal ID
          final status = AttendanceStatus.values[data['status'] as int];
          try {
            await (_db.update(_db.fravaersPoster)
                  ..where((p) => p.id.equals(postId)))
                .write(FravaersPosterCompanion(
              status: Value(status),
              forsinkelsesMinutter: Value(data['forsinkelsesMinutter'] as int?),
              merknad: Value(data['merknad'] as String?),
            ));
          } catch (e) {
            debugPrint('Sharing-lytter: lokal oppdatering feilet: $e');
          }
        }
      }
    }, onError: (e) {
      debugPrint('Sharing-lytter: Firestore-feil: $e');
    });

    _listeners[shareId] = sub;
  }

  void stopListening(String shareId) {
    _listeners[shareId]?.cancel();
    _listeners.remove(shareId);
  }

  Future<void> pushStatusUpdate({
    required String shareId,
    required String postId,
    required AttendanceStatus status,
    int? forsinkelsesMinutter,
    String? merknad,
  }) async {
    try {
      await _firestore
          .collection('sharedSessions')
          .doc(shareId)
          .collection('records')
          .doc(postId)
          .update({
        'status': status.index,
        'forsinkelsesMinutter': forsinkelsesMinutter,
        'merknad': merknad,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Sharing: push feilet (offline?): $e');
    }
  }

  // ─── Slett skydata ───────────────────────────────────────────────

  Future<void> deleteSharedSession(String shareId) async {
    stopListening(shareId);

    final records = await _firestore
        .collection('sharedSessions')
        .doc(shareId)
        .collection('records')
        .get();

    final batch = _firestore.batch();
    for (final doc in records.docs) {
      batch.delete(doc.reference);
    }

    final sessionDoc =
        await _firestore.collection('sharedSessions').doc(shareId).get();
    if (sessionDoc.exists) {
      final code = sessionDoc.data()?['inviteCode'] as String?;
      if (code != null) {
        batch.delete(_firestore.collection('sessionCodes').doc(code));
      }
      batch.delete(sessionDoc.reference);
    }

    await batch.commit();

    await (_db.update(_db.fravaersOkter)..where((s) => s.shareId.equals(shareId)))
        .write(const FravaersOkterCompanion(shareId: Value(null)));
  }

  void dispose() {
    for (final sub in _listeners.values) {
      sub.cancel();
    }
    _listeners.clear();
  }
}
