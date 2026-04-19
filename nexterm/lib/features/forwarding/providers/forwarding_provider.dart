import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/repositories/port_forward_repository_impl.dart';
import 'package:nexterm/domain/entities/port_forward_entity.dart';
import 'package:nexterm/domain/repositories/port_forward_repository.dart';
import 'package:nexterm/main.dart';
import 'package:uuid/uuid.dart';

final portForwardRepositoryProvider = Provider<PortForwardRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return PortForwardRepositoryImpl(db.portForwardsDao);
});

final forwardsStreamProvider = StreamProvider<List<PortForwardEntity>>((ref) {
  return ref.watch(portForwardRepositoryProvider).watchAll();
});

final forwardsByHostProvider = StreamProvider.family<List<PortForwardEntity>, String>((ref, hostId) {
  return ref.watch(portForwardRepositoryProvider).watchByHostId(hostId);
});

class ForwardingNotifier extends StateNotifier<AsyncValue<void>> {
  final PortForwardRepository _repo;
  ForwardingNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> addForward(PortForwardEntity forward) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.insert(forward.copyWith(id: const Uuid().v4()));
    });
  }

  Future<void> updateForward(PortForwardEntity forward) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.update(forward));
  }

  Future<void> deleteForward(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(id));
  }
}

final forwardingNotifierProvider = StateNotifierProvider<ForwardingNotifier, AsyncValue<void>>((ref) {
  return ForwardingNotifier(ref.watch(portForwardRepositoryProvider));
});
