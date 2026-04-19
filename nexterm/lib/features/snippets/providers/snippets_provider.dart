import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexterm/data/repositories/snippet_repository_impl.dart';
import 'package:nexterm/domain/entities/snippet_entity.dart';
import 'package:nexterm/domain/repositories/snippet_repository.dart';
import 'package:nexterm/main.dart';
import 'package:uuid/uuid.dart';

final snippetRepositoryProvider = Provider<SnippetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SnippetRepositoryImpl(db.snippetsDao);
});

final snippetsStreamProvider = StreamProvider<List<SnippetEntity>>((ref) {
  return ref.watch(snippetRepositoryProvider).watchAll();
});

final snippetSearchProvider = FutureProvider.family<List<SnippetEntity>, String>((ref, query) {
  final repo = ref.watch(snippetRepositoryProvider);
  if (query.isEmpty) return repo.getAll();
  return repo.search(query);
});

final snippetByIdProvider = FutureProvider.family<SnippetEntity?, String>((ref, id) {
  return ref.watch(snippetRepositoryProvider).getById(id);
});

class SnippetsNotifier extends StateNotifier<AsyncValue<void>> {
  final SnippetRepository _repo;
  SnippetsNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> addSnippet(SnippetEntity snippet) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.insert(snippet.copyWith(id: const Uuid().v4()));
    });
  }

  Future<void> updateSnippet(SnippetEntity snippet) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.update(snippet));
  }

  Future<void> deleteSnippet(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.delete(id));
  }

  Future<void> toggleFavorite(SnippetEntity snippet) async {
    await _repo.update(snippet.copyWith(isFavorite: !snippet.isFavorite));
  }
}

final snippetsNotifierProvider = StateNotifierProvider<SnippetsNotifier, AsyncValue<void>>((ref) {
  return SnippetsNotifier(ref.watch(snippetRepositoryProvider));
});
