// =============================================================================
// se_text_field.dart - TextField de StoryEnglish
// -----------------------------------------------------------------------------
// TextField con estilo consistente (bordes redondeados, fuente Fredoka),
// soporte para icono prefix/suffix, error text, y label.
// =============================================================================

import 'package:flutter/material.dart';

import '../config/theme.dart';

/// TextField con estilo de StoryEnglish Kids.
class SETextField extends StatelessWidget {
  const SETextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.maxLines = 1,
    this.maxLength,
    this.autofocus = false,
    this.errorText,
    this.helperText,
    this.textAlign = TextAlign.start,
    this.fillColor,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? maxLength;
  final bool autofocus;
  final String? errorText;
  final String? helperText;
  final TextAlign textAlign;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autofocus,
      textAlign: textAlign,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        errorText: errorText,
        helperText: helperText,
        filled: inputTheme.filled,
        fillColor: fillColor ?? inputTheme.fillColor,
        contentPadding: inputTheme.contentPadding,
        border: inputTheme.border,
        enabledBorder: inputTheme.enabledBorder,
        focusedBorder: inputTheme.focusedBorder,
        errorBorder: inputTheme.errorBorder,
        focusedErrorBorder: inputTheme.errorBorder?.copyWith(
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
        labelStyle: inputTheme.labelStyle,
        hintStyle: inputTheme.hintStyle,
      ),
    );
  }
}

/// Variante de TextField para busquedas (con icono lupa y boton clear).
class SESearchField extends StatelessWidget {
  const SESearchField({
    super.key,
    required this.controller,
    this.hint = 'Buscar...',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return SETextField(
          controller: controller,
          hint: hint,
          prefixIcon: Icons.search,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          autofocus: autofocus,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          suffixIcon: value.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onChanged?.call('');
                  },
                  tooltip: 'Limpiar',
                ),
        );
      },
    );
  }
}
