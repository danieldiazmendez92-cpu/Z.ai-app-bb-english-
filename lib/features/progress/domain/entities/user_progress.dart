import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';
part 'user_progress.g.dart';

/// Progreso de un niño en un cuento específico.
///
/// Se actualiza en tiempo real durante la lectura (cada 10 segundos).
/// Permite:
/// - Reanudar lectura donde quedó
/// - Mostrar "continuar leyendo" en Home
/// - Calcular cuentos completados
/// - Trigger de logros (Cloud Function `onStoryCompleted`)
@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    /// ID compuesto: '{childId}_{storyId}'
    required String progressId,

    /// FK al niño.
    required String childId,

    /// FK al cuento.
    required String storyId,

    /// Título del cuento (denormalizado para evitar reads extra).
    required String storyTitle,

    /// URL de la portada del cuento (denormalizado).
    required String storyCoverUrl,

    /// Porcentaje de completion (0-100).
    @Default(0) int completionPct,

    /// Tiempo total de lectura en segundos.
    @Default(0) int timeSpentSeconds,

    /// Última sección leída (para reanudar).
    @Default(0) int lastSectionOrder,

    /// True si el niño terminó el cuento.
    @Default(false) bool completed,

    /// Fecha de completion (si completed = true).
    DateTime? completedAt,

    required DateTime lastReadAt,

    required DateTime createdAt,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);

  const UserProgress._();

  /// True si el cuento está en progreso (empezó pero no terminó).
  bool get isInProgress => completionPct > 0 && !completed;
}
