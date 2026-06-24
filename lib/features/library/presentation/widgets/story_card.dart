import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../story/domain/entities/story.dart';

/// Card que muestra un cuento en grid o lista.
///
/// Muestra: portada, título, edad recomendada, duración.
/// Al tap, navega a StoryDetailScreen.
class StoryCard extends StatelessWidget {
  const StoryCard({
    super.key,
    required this.story,
    this.width,
    this.height,
  });

  final Story story;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.storyDetailFor(story.storyId)),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada con Hero animation a StoryDetailScreen
            Expanded(
              flex: 3,
              child: Hero(
                tag: 'story-cover-${story.storyId}',
                child: _buildCover(context),
              ),
            ),
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.cake_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          story.ageRange,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const Spacer(),
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${story.durationMinutes} min',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    if (story.coverImageUrl.isEmpty) {
      // Placeholder si no hay portada
      return Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Center(
          child: Icon(
            Icons.auto_stories,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    // Si es un emoji (de testing), mostrarlo grande
    if (story.coverImageUrl.length <= 4 &&
        RegExp(r'^[\p{L}\p{S}]$', unicode: true)
            .hasMatch(story.coverImageUrl)) {
      return Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Center(
          child: Text(
            story.coverImageUrl,
            style: const TextStyle(fontSize: 56),
          ),
        ),
      );
    }

    // Si es URL, cargar imagen
    if (story.coverImageUrl.startsWith('http') ||
        story.coverImageUrl.startsWith('gs://')) {
      return CachedNetworkImage(
        imageUrl: story.coverImageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Theme.of(context).colorScheme.surface,
        ),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: const Center(child: Icon(Icons.error_outline)),
        ),
      );
    }

    // Si es asset path
    return Image.asset(
      story.coverImageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, child) => Container(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Center(
          child: Icon(
            Icons.auto_stories,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
