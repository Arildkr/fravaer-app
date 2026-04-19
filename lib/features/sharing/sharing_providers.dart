import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import 'data/session_sharing_service.dart';

final sessionSharingServiceProvider = Provider<SessionSharingService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = SessionSharingService(db: db);
  ref.onDispose(service.dispose);
  return service;
});
