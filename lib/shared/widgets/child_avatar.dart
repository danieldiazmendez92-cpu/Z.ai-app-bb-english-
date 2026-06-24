// =============================================================================
// child_avatar.dart - Widget de avatar del nio
// -----------------------------------------------------------------------------
// SKELETON: muestra el avatar del nio desde un asset path o URL.
// Placeholder mientras se integran los assets reales en Fase 1.
// =============================================================================

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/config/theme.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/widgets/se_loading_indicator.dart';

/// Tamano del avatar.
enum ChildAvatarSize {
  small(32),
  medium(48),
  large(72),
  xlarge(120);

  const ChildAvatarSize(this.pixels);
  final double pixels;
}

/// Avatar del nio. Soporta asset local (avatares predefinidos) o URL remota
/// (avatar subido por el padre).
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({
    super.key,
    this.assetPath,
    this.imageUrl,
    this.name,
    this.size = ChildAvatarSize.medium,
    this.onTap,
    this.showRing = false,
  }) : assert(
          assetPath != null || imageUrl != null,
          'Debe proveer assetPath o imageUrl',
        );

  /// Path a asset local (uno de AssetPaths.avatar*).
  final String? assetPath;

  /// URL remota (ej: Storage URL del avatar subido).
  final String? imageUrl;

  /// Nombre del nio (para mostrar inicial como fallback).
  final String? name;

  /// Tamano del avatar.
  final ChildAvatarSize size;

  /// Callback al tap (ej: abrir child picker).
  final VoidCallback? onTap;

  /// Si `true`, muestra un anillo colorido alrededor (estilo seleccionado).
  final bool showRing;

  @override
  Widget build(BuildContext context) {
    final avatarWidget = _buildAvatar(context);

    final content = showRing
        ? Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [SEColors.primary, SEColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: avatarWidget,
          )
        : avatarWidget;

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  Widget _buildAvatar(BuildContext context) {
    final sizePx = size.pixels;

    if (imageUrl != null) {
      return SizedBox(
        width: sizePx,
        height: sizePx,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!,
            width: sizePx,
            height: sizePx,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SELoadingIndicator(),
            errorWidget: (context, url, error) => _fallback(context),
          ),
        ),
      );
    }

    // Asset local
    return SizedBox(
      width: sizePx,
      height: sizePx,
      child: ClipOval(
        child: Image.asset(
          assetPath ?? AssetPaths.avatarFox,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => _fallback(context),
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    // Placeholder con inicial del nombre o icono generico.
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    return Container(
      color: SEColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size.pixels * 0.5,
          fontWeight: FontWeight.bold,
          color: SEColors.primary,
        ),
      ),
    );
  }
}
