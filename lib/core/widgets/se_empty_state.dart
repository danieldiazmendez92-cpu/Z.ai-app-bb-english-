// =============================================================================
// se_empty_state.dart - Estado vacio reutilizable
// -----------------------------------------------------------------------------
// Muestra ilustracion + titulo + mensaje + CTA opcional cuando una lista
// esta vacia (sin cuentos, sin logros, sin progreso, etc.).
// =============================================================================

import 'package:flutter/material.dart';

import '../config/theme.dart';
import 'se_button.dart';

/// Estado vacio con ilustracion, titulo, mensaje y CTA opcional.
class SEEmptyState extends StatelessWidget {
  const SEEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.sentiment_satisfied,
    this.iconColor,
    this.ctaLabel,
    this.onCtaPressed,
    this.illustrationAsset,
  });

  /// Titulo corto (1-3 palabras).
  final String title;

  /// Mensaje descriptivo (1-2 lineas).
  final String message;

  /// Icono Material (default: carita feliz). Si [illustrationAsset] se
  /// provee, se usa la ilustracion Lottie/PNG en su lugar.
  final IconData icon;

  /// Color del icono (default: textHint).
  final Color? iconColor;

  /// Etiqueta del CTA opcional (boton accion).
  final String? ctaLabel;

  /// Callback del CTA.
  final VoidCallback? onCtaPressed;

  /// Path a asset (imagen o Lottie) para reemplazar el icono.
  final String? illustrationAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIllustration(context),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: SEColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onCtaPressed != null) ...[
              const SizedBox(height: 24),
              SEButton(
                label: ctaLabel!,
                icon: Icons.add,
                onPressed: onCtaPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    if (illustrationAsset != null) {
      // TODO(P1): integrar Lottie cuando se agreguen los assets.
      return Image.asset(
        illustrationAsset!,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stack) => _fallbackIcon(context),
      );
    }
    return _fallbackIcon(context);
  }

  Widget _fallbackIcon(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: SEColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 64,
        color: iconColor ?? SEColors.primary,
      ),
    );
  }
}
