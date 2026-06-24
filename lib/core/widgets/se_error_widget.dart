// =============================================================================
// se_error_widget.dart - Widget de error reutilizable
// -----------------------------------------------------------------------------
// Muestra un estado de error con icono, mensaje y boton de reintentar.
// Pensado para usar dentro de AsyncValue.when(error: ...) o como fallback.
// =============================================================================

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../errors/failures.dart';
import 'se_button.dart';

/// Widget de error con icono, mensaje y accion de reintentar opcional.
class SEErrorWidget extends StatelessWidget {
  const SEErrorWidget({
    super.key,
    required this.message,
    this.failure,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.title,
  });

  /// Construye desde un `Failure` de dominio.
  factory SEErrorWidget.fromFailure(
    Failure failure, {
    VoidCallback? onRetry,
    Key? key,
  }) {
    return SEErrorWidget(
      key: key,
      message: failure.userMessage,
      failure: failure,
      onRetry: failure.isRetryable ? onRetry : null,
    );
  }

  /// Construye desde un error generico (Object?).
  factory SEErrorWidget.fromError(
    Object? error, {
    VoidCallback? onRetry,
    Key? key,
  }) {
    if (error is Failure) {
      return SEErrorWidget.fromFailure(error, onRetry: onRetry, key: key);
    }
    return SEErrorWidget(
      key: key,
      message: error?.toString() ?? 'Error desconocido',
      onRetry: onRetry,
    );
  }

  /// Mensaje principal visible al usuario.
  final String message;

  /// Failure original (opcional, para loggear o mostrar codigo).
  final Failure? failure;

  /// Callback al tap en "Reintentar". Si null, no muestra boton.
  final VoidCallback? onRetry;

  /// Icono a mostrar (default: error_outline).
  final IconData icon;

  /// Titulo opcional arriba del mensaje.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: SEColors.error),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: SEColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (failure != null && failure!.code != 'unknown') ...[
              const SizedBox(height: 8),
              Text(
                'Codigo: ${failure!.code}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SEColors.textHint,
                  fontFamily: 'monospace',
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SEButton(
                label: 'Reintentar',
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
