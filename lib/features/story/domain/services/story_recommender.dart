import 'dart:math';

/// Algoritmo simple de recomendación de cuentos basado en:
/// 1. Filtro por edad (min_age <= age <= max_age)
/// 2. Score por coincidencia de tags con intereses del niño
/// 3. Score por popularidad (view_count)
/// 4. Penalización por cuentos ya leídos
///
/// No es ML, pero da resultados razonables para MVP.
/// En Fase 4 se puede migrar a un modelo más sofisticado.
class StoryRecommender {
  StoryRecommender();

  /// Pesos del score
  static const double _interestWeight = 10.0;
  static const double _popularityWeight = 0.01;
  static const double _recencyWeight = 0.5;
  static const double _readPenalty = 100.0;

  /// Ordena los cuentos por score de recomendación descendente.
  List<T> recommend<T>({
    required List<T> stories,
    required int age,
    required List<String> interests,
    required Set<String> readStoryIds,
    required String Function(T) storyIdGetter,
    required int Function(T) minAgeGetter,
    required int Function(T) maxAgeGetter,
    required List<String> Function(T) tagsGetter,
    required int Function(T) viewCountGetter,
    required DateTime Function(T) createdAtGetter,
    int limit = 10,
  }) {
    final now = DateTime.now();

    final scored = stories.map((story) {
      final minAge = minAgeGetter(story);
      final maxAge = maxAgeGetter(story);
      if (age < minAge || age > maxAge) {
        return _Scored(story, -1000);
      }

      double score = 0;
      final tags = tagsGetter(story).map((t) => t.toLowerCase()).toSet();
      for (final interest in interests) {
        if (tags.contains(interest.toLowerCase())) {
          score += _interestWeight;
        }
      }

      score += viewCountGetter(story) * _popularityWeight;

      final daysOld = now.difference(createdAtGetter(story)).inDays;
      score += max(0, 30 - daysOld) * _recencyWeight / 30;

      if (readStoryIds.contains(storyIdGetter(story))) {
        score -= _readPenalty;
      }

      return _Scored(story, score);
    }).toList();

    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).map((s) => s.value).toList();
  }
}

class _Scored<T> {
  const _Scored(this.value, this.score);
  final T value;
  final double score;
}
