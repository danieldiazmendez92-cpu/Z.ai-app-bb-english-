import 'package:flutter/material.dart';

import '../../domain/entities/achievement.dart';

/// Insignia de un logro. Puede estar desbloqueada o bloqueada.
///
/// Si está desbloqueada: muestra el emoji a color + nombre + descripción.
/// Si está bloqueada: muestra silueta en gris + nombre + "?" en descripción
/// (o el criterio si no es oculto).
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    required this.isUnlocked,
    this.onTap,
    this.size = 100,
  });

  final Achievement achievement;
  final bool isUnlocked;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final emoji = achievement.emoji ?? achievement.iconUrl;

    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnlocked
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnlocked
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              width: isUnlocked ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji/icono
              Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isUnlocked
                      ? Text(
                          emoji,
                          style: TextStyle(fontSize: size * 0.3),
                        )
                      : Icon(
                          Icons.lock_outline,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          size: size * 0.2,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              // Nombre
              Text(
                achievement.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              // Descripción (si no es oculto o si está desbloqueado)
              if (isUnlocked || !achievement.isHidden) ...[
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ] else ...[
                const SizedBox(height: 2),
                Text(
                  '???',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
