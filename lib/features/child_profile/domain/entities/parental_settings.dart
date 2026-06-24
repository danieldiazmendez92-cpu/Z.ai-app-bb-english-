import 'package:freezed_annotation/freezed_annotation.dart';

part 'parental_settings.freezed.dart';
part 'parental_settings.g.dart';

/// Configuración parental del usuario (padre/madre).
///
/// Cada usuario tiene un único documento `parental_settings/{userUid}`.
/// Se crea automáticamente por Cloud Function `onUserCreate` cuando el
/// usuario se registra.
@freezed
class ParentalSettings with _$ParentalSettings {
  const factory ParentalSettings({
    /// UID del padre dueño de esta configuración (PK).
    required String userUid,

    /// Límite diario de uso en minutos. 0 = sin límite.
    /// Máximo 480 (8 horas).
    @Default(0) int dailyLimitMinutes,

    /// Categorías bloqueadas (no se muestran en Library ni Home).
    /// Ej: ['scary', 'sensitive']
    @Default(<String>[]) List<String> blockedCategories,

    /// Permitir descarga de cuentos para uso offline.
    @Default(true) bool allowOfflineDownload,

    /// Opt-in para analytics. COPPA requiere opt-in explícito.
    /// Default: false (no se recopilan datos analíticos del niño).
    @Default(false) bool allowAnalytics,

    /// Permitir anuncios personalizados. SIEMPRE false (COPPA lo prohíbe).
    @Default(false) bool allowPersonalizedAds,

    /// Hora de inicio del bloqueo nocturno (formato HH:mm 24h).
    /// Ej: '20:00' significa que desde las 20:00 la app se bloquea.
    String? bedtimeStart,

    /// Hora de fin del bloqueo nocturno.
    /// Ej: '07:00' significa que desde las 07:00 se desbloquea.
    String? bedtimeEnd,
  }) = _ParentalSettings;

  factory ParentalSettings.fromJson(Map<String, dynamic> json) =>
      _$ParentalSettingsFromJson(json);

  const ParentalSettings._();

  /// True si hay configurado un bloqueo nocturno.
  bool get hasBedtime => bedtimeStart != null && bedtimeEnd != null;
}
