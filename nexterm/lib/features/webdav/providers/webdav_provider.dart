import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/database/daos/webdav_connections_dao.dart';
import 'package:nexterm/domain/entities/webdav_connection_entity.dart';
import 'package:nexterm/main.dart';

final webdavDaoProvider = Provider<WebdavConnectionsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.webdavConnectionsDao;
});

final webdavConnectionsStreamProvider = StreamProvider<List<WebdavConnectionEntity>>((ref) {
  return ref.watch(webdavDaoProvider).watchAll();
});

final webdavConnectionByIdProvider = FutureProvider.family<WebdavConnectionEntity?, String>((ref, id) {
  return ref.watch(webdavDaoProvider).getById(id);
});

final webdavSearchProvider = FutureProvider.family<List<WebdavConnectionEntity>, String>((ref, query) {
  return ref.watch(webdavDaoProvider).search(query);
});
