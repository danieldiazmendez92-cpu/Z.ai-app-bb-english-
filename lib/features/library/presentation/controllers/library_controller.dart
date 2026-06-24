import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failures.dart';
import '../../../library/domain/entities/category.dart';
import '../../../story/domain/entities/story.dart';
import '../../../story/domain/repositories/story_repository.dart';
import '../../../story/presentation/providers/story_provider.dart';

/// Estado de la pantalla Library.
class LibraryState {
  const LibraryState({
    this.stories = const AsyncValue.loading(),
    this.selectedCategoryId,
    this.selectedAge,
    this.searchQuery = '',
  });

  final AsyncValue<List<Story>> stories;
  final String? selectedCategoryId;
  final int? selectedAge;
  final String searchQuery;

  LibraryState copyWith({
    AsyncValue<List<Story>>? stories,
    String? selectedCategoryId,
    int? selectedAge,
    String? searchQuery,
  }) {
    return LibraryState(
      stories: stories ?? this.stories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedAge: selectedAge ?? this.selectedAge,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Controller de la pantalla Library.
///
/// Maneja:
/// - Carga del catálogo de cuentos publicados
/// - Filtros por categoría y edad
/// - Búsqueda por título
class LibraryController extends StateNotifier<LibraryState> {
  LibraryController({required StoryRepository repository})
      : _repository = repository,
        super(const LibraryState()) {
    loadStories();
  }

  final StoryRepository _repository;

  /// Carga los cuentos aplicando los filtros actuales.
  Future<void> loadStories() async {
    state = state.copyWith(stories: const AsyncValue.loading());
    try {
      final stories = await _repository.getPublishedStories(
        categoryId: state.selectedCategoryId,
        age: state.selectedAge,
      );
      state = state.copyWith(stories: AsyncValue.data(stories));
    } on Failure catch (e, st) {
      state = state.copyWith(stories: AsyncValue.error(e, st));
    } catch (e, st) {
      state = state.copyWith(
          stories: AsyncValue.error(UnknownFailure(e.toString()), st));
    }
  }

  /// Setea el filtro de categoría y recarga.
  /// Si [categoryId] es null, limpia el filtro.
  Future<void> setCategory(String? categoryId) async {
    state = state.copyWith(selectedCategoryId: categoryId);
    await loadStories();
  }

  /// Setea el filtro de edad y recarga.
  /// Si [age] es null, limpia el filtro.
  Future<void> setAge(int? age) async {
    state = state.copyWith(selectedAge: age);
    await loadStories();
  }

  /// Busca cuentos por título.
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    if (query.trim().isEmpty) {
      await loadStories();
      return;
    }
    try {
      final results = await _repository.searchStories(query);
      state = state.copyWith(stories: AsyncValue.data(results));
    } catch (e, st) {
      state = state.copyWith(
          stories: AsyncValue.error(UnknownFailure(e.toString()), st));
    }
  }

  /// Limpia todos los filtros.
  Future<void> clearFilters() async {
    state = const LibraryState();
    await loadStories();
  }
}

// ============================================================
// Providers
// ============================================================

final libraryControllerProvider =
    StateNotifierProvider<LibraryController, LibraryState>((ref) {
  return LibraryController(
    repository: ref.watch(storyRepositoryProvider),
  );
});

/// Provider de categorías (catálogo estático por ahora, en el futuro desde Firestore).
final categoriesProvider = Provider<List<Category>>((ref) {
  return const [
    Category(
      categoryId: 'animals',
      name: 'Animals',
      nameEs: 'Animales',
      iconAsset: '🐾',
      order: 1,
    ),
    Category(
      categoryId: 'adventure',
      name: 'Adventure',
      nameEs: 'Aventuras',
      iconAsset: '🚀',
      order: 2,
    ),
    Category(
      categoryId: 'bedtime',
      name: 'Bedtime',
      nameEs: 'Hora de dormir',
      iconAsset: '🌙',
      order: 3,
    ),
    Category(
      categoryId: 'fairy',
      name: 'Fairy Tales',
      nameEs: 'Cuentos de hadas',
      iconAsset: '🧚',
      order: 4,
    ),
    Category(
      categoryId: 'learning',
      name: 'Learning',
      nameEs: 'Aprender',
      iconAsset: '📚',
      order: 5,
    ),
    Category(
      categoryId: 'classic',
      name: 'Classics',
      nameEs: 'Clásicos',
      iconAsset: '📖',
      order: 6,
    ),
  ];
});
