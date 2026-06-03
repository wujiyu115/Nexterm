import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/database/daos/smb_connections_dao.dart';
import 'package:nexterm/domain/entities/smb_connection_entity.dart';
import 'package:nexterm/main.dart';

final smbDaoProvider = Provider<SmbConnectionsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.smbConnectionsDao;
});

final smbConnectionsStreamProvider = StreamProvider<List<SmbConnectionEntity>>((ref) {
  return ref.watch(smbDaoProvider).watchAll();
});

final smbConnectionByIdProvider = FutureProvider.family<SmbConnectionEntity?, String>((ref, id) {
  return ref.watch(smbDaoProvider).getById(id);
});

final smbSearchProvider = FutureProvider.family<List<SmbConnectionEntity>, String>((ref, query) {
  return ref.watch(smbDaoProvider).search(query);
});
