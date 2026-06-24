import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Servicio de feedback háptico + sonoro.
///
/// Por ahora solo implementa haptics (vibración). Los sonidos de feedback
/// se agregan en una Fase posterior con archivos de audio cortos.
///
/// Tipos de feedback:
/// - **tap**: vibración muy leve al tocar un botón
/// - **success**: vibración media + (futuro) sonido de éxito
/// - **error**: vibración fuerte + (futuro) sonido de error
/// - **achievement**: vibración patrón + (futuro) sonido de logro
class FeedbackService {
  Future<void> tap() => HapticFeedback.selectionClick();

  Future<void> success() => HapticFeedback.mediumImpact();

  Future<void> error() => HapticFeedback.heavyImpact();

  Future<void> achievement() async {
    // Patrón de vibración para logro: 3 vibraciones rápidas + una larga
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 200));
    await HapticFeedback.heavyImpact();
  }
}

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService();
});
