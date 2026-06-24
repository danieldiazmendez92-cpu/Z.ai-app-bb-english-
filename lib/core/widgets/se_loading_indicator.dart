// =============================================================================
// se_loading_indicator.dart - Indicador de carga
// -----------------------------------------------------------------------------
// Wrapper sobre CircularProgressIndicator con tamaos predefinidos y soporte
// para overlay fullscreen.
// =============================================================================

import 'package:flutter/material.dart';

import '../config/theme.dart';

/// Tamano del indicador de carga.
enum SELoadingSize {
  small(16),
  regular(24),
  large(48);

  const SELoadingSize(this.pixels);
  final double pixels;
}

/// Indicador de carga circular.
class SELoadingIndicator extends StatelessWidget {
  const SELoadingIndicator({
    super.key,
    this.size = SELoadingSize.regular,
    this.color,
    this.strokeWidth = 2.5,
  })  : assert(size.pixels > 0),
        assert(strokeWidth > 0);

  /// Tamano predefinido (small=16, regular=24, large=48).
  final SELoadingSize size;

  /// Color del spinner. Si null, usa el color primario del theme.
  final Color? color;

  /// Grosor de la linea.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.pixels,
      height: size.pixels,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Overlay fullscreen con spinner centrado y mensaje opcional.
/// Util para mostrar mientras se procesa una accion bloqueante.
class SELoadingOverlay extends StatelessWidget {
  const SELoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor,
  });

  /// Mensaje opcional debajo del spinner.
  final String? message;

  /// Color del overlay (semi-transparente por defecto).
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.black.withOpacity(0.4),
      child: Center(
        child: Card(
          color: SEColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SELoadingIndicator(size: SELoadingSize.large),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para usar dentro de AsyncValue.when(loading:).
/// Muestra spinner centrado en el area disponible.
class SELoadingState extends StatelessWidget {
  const SELoadingState({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SELoadingIndicator(size: SELoadingSize.large),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SEColors.textSecondary,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
