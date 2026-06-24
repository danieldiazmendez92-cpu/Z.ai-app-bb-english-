// =============================================================================
// se_button.dart - Boton primario de StoryEnglish
// -----------------------------------------------------------------------------
// Boton con:
//  - Tap target minimo 48dp (Material guidelines + accesibilidad infantil).
//  - Estados: enabled, disabled, loading, error.
//  - Variants: primary (filled), secondary (outlined), text.
//  - Sizes: regular (52dp), large (56dp para CTA principal).
//  - Bordes redondeados (radiusMedium = 16) y fuente Fredoka.
// =============================================================================

import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../constants/app_constants.dart';
import 'se_loading_indicator.dart';

/// Variante visual del boton.
enum SEButtonVariant {
  /// Boton primario (filled, color principal).
  primary,

  /// Boton secundario (outlined).
  secondary,

  /// Boton de texto (sin fondo ni borde).
  text,

  /// Boton peligroso (filled, color error).
  destructive,
}

/// Tamano del boton.
enum SEButtonSize {
  /// Altura 48dp (minimo accesible).
  small,

  /// Altura 52dp (default, recomendado para nios).
  regular,

  /// Altura 56dp (CTA principal de pantalla).
  large,
}

/// Boton primario de StoryEnglish Kids.
///
/// Ejemplo:
/// ```dart
/// SEButton(
///   label: 'Empezar a leer',
///   icon: Icons.play_arrow,
///   onPressed: () => startReading(),
/// ),
/// ```
class SEButton extends StatelessWidget {
  const SEButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = SEButtonVariant.primary,
    this.size = SEButtonSize.regular,
    this.isLoading = false,
    this.isExpanded = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Texto del boton.
  final String label;

  /// Callback al tap. Si `null`, el boton se muestra deshabilitado.
  final VoidCallback? onPressed;

  /// Icono opcional a la izquierda del texto.
  final IconData? icon;

  /// Variante visual.
  final SEButtonVariant variant;

  /// Tamano del boton.
  final SEButtonSize size;

  /// Muestra un spinner en lugar del icono y deshabilita el boton.
  final bool isLoading;

  /// Si `true`, ocupa todo el ancho disponible.
  final bool isExpanded;

  /// Color de fondo (override del theme).
  final Color? backgroundColor;

  /// Color de texto/icono (override del theme).
  final Color? foregroundColor;

  /// `true` si el boton esta deshabilitado (onPressed null o isLoading true).
  bool get _isDisabled => onPressed == null || isLoading;

  double get _height => switch (size) {
        SEButtonSize.small => AppConstants.minTapTarget,
        SEButtonSize.regular => 52,
        SEButtonSize.large => 56,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = backgroundColor ?? _defaultBackground(colorScheme);
    final fg = foregroundColor ?? _defaultForeground(colorScheme);

    Widget content = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SELoadingIndicator(size: 18, color: Colors.white)
        else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: fg),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
    );

    final constraints = BoxConstraints(
      minHeight: _height,
      maxHeight: _height,
    );

    if (variant == SEButtonVariant.text) {
      return TextButton(
        onPressed: _isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: fg,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: content,
      );
    }

    if (variant == SEButtonVariant.secondary) {
      return OutlinedButton(
        onPressed: _isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          backgroundColor: Colors.transparent,
          side: BorderSide(color: fg, width: 2),
          shape: shape,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: _constrainedContent(content, constraints),
      );
    }

    // primary y destructive usan ElevatedButton
    return ElevatedButton(
      onPressed: _isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: fg,
        backgroundColor: bg,
        disabledBackgroundColor: bg.withOpacity(0.5),
        disabledForegroundColor: fg.withOpacity(0.7),
        elevation: 0,
        shape: shape,
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: _constrainedContent(content, constraints),
    );
  }

  Widget _constrainedContent(Widget content, BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: constraints,
      child: isExpanded
          ? content
          : IntrinsicWidth(child: content),
    );
  }

  Color _defaultBackground(ColorScheme scheme) {
    if (_isDisabled) {
      return scheme.surfaceContainerHighest;
    }
    return switch (variant) {
      SEButtonVariant.primary => scheme.primary,
      SEButtonVariant.secondary => Colors.transparent,
      SEButtonVariant.text => Colors.transparent,
      SEButtonVariant.destructive => SEColors.error,
    };
  }

  Color _defaultForeground(ColorScheme scheme) {
    if (_isDisabled) {
      return scheme.onSurface.withOpacity(0.5);
    }
    return switch (variant) {
      SEButtonVariant.primary => Colors.white,
      SEButtonVariant.secondary => scheme.primary,
      SEButtonVariant.text => scheme.primary,
      SEButtonVariant.destructive => Colors.white,
    };
  }
}
