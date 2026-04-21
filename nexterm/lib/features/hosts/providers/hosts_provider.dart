import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/repositories/host_repository_impl.dart';
import 'package:nexterm/domain/entities/host_entity.dart';
import 'package:nexterm/domain/repositories/host_repository.dart';
import 'package:nexterm/main.dart';
import 'package:uuid/uuid.dart';

final hostRepositoryProvider = Provider<HostRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HostRepositoryImpl(db.hostsDao);
});

final hostsStreamProvider = StreamProvider<List<HostEntity>>((ref) {
  return ref.watch(hostRepositoryProvider).watchAll();
});

final hostSearchProvider = FutureProvider.family<List<HostEntity>, String>((ref, query) {
  final repo = ref.watch(hostRepositoryProvider);
  if (query.isEmpty) return repo.getAll();
  return repo.search(query);
});

final hostByIdProvider = FutureProvider.family<HostEntity?, String>((ref, id) {
  return ref.watch(hostRepositoryProvider).getById(id);
});

class HostsNotifier extends StateNotifier<AsyncValue<void>> {
  final HostRepository _repo;
  HostsNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> addHost(HostEntity host) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.insert(host.copyWith(id: const Uuid().v4()));
    });
  }

  Future<void> updateHost(HostEntity host) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.update(host));
  }

  Future<void> deleteHost(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(id));
  }

  Future<void> deleteMultiple(List<String> ids) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.deleteMultiple(ids));
  }

  Future<void> toggleFavorite(HostEntity host) async {
    await _repo.update(host.copyWith(isFavorite: !host.isFavorite));
  }

  Future<void> updateLastConnected(String hostId) async {
    final host = await _repo.getById(hostId);
    if (host != null) {
      await _repo.update(host.copyWith(lastConnected: () => DateTime.now()));
    }
  }

  /// Duplicates a host by copying its configuration with a new ID and name.
  Future<void> duplicateHost(String hostId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final host = await _repo.getById(hostId);
      if (host == null) return;
      await _repo.insert(host.copyWith(
        id: const Uuid().v4(),
        name: '${host.name} (copy)',
        lastConnected: () => null,
      ));
    });
  }

  /// Moves a single host to a different group.
  Future<void> moveToGroup(String hostId, String? group) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final host = await _repo.getById(hostId);
      if (host == null) return;
      await _repo.update(host.copyWith(group: () => group));
    });
  }

  /// Moves multiple hosts to a different group.
  Future<void> moveMultipleToGroup(List<String> ids, String? group) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      for (final id in ids) {
        final host = await _repo.getById(id);
        if (host != null) {
          await _repo.update(host.copyWith(group: () => group));
        }
      }
    });
  }
}

final hostsNotifierProvider = StateNotifierProvider<HostsNotifier, AsyncValue<void>>((ref) {
  return HostsNotifier(ref.watch(hostRepositoryProvider));
});
