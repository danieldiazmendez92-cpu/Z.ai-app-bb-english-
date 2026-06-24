// =============================================================================
// story_grid.dart - Grid de cuentos (placeholder)
// -----------------------------------------------------------------------------
// SKELETON: widget reutilizable que muestra cuentos en grid.
// En Fase 1 se conectara al StoryRepository y mostrara StoryCards reales.
// =============================================================================

import 'package:flutter/material.dart';

import '../../core/config/theme.dart';
import '../../core/widgets/se_empty_state.dart';
import '../../core/widgets/se_error_widget.dart';
import '../../core/widgets/se_loading_indicator.dart';

/// DTO temporal para item del grid.
/// En Fase 1 se reemplaza por `Story` (modelo freezed de docs/03).
class StoryGridItem {
  const StoryGridItem({
    required this.storyId,
    required this.title,
    required this.coverUrl,
    this.durationMinutes = 5,
  });
  final String storyId;
  final String title;
  final String coverUrl;
  final int durationMinutes;
}

/// Estado del grid - placeholder para que el widget compile sin Riverpod
/// dependency circular. En Fase 1 se reemplaza por AsyncValue<List<Story>>.
class StoryGridData {
  const StoryGridData({this.items = const [], this.isLoading = false, this.error});
  final List<StoryGridItem> items;
  final bool isLoading;
  final Object? error;
}

/// Grid de cuentos con estados loading / error / empty / data.
///
/// SKELETON - en Fase 1 se leera de storyControllerProvider.
class StoryGrid extends StatelessWidget {
  const StoryGrid({
    super.key,
    required this.data,
    this.onTapItem,
    this.crossAxisCount = 2,
    this.emptyTitle = 'No hay cuentos',
    this.emptyMessage = 'Vuelve mas tarde, estamos agregando nuevos cuentos!',
  });

  final StoryGridData data;
  final void Function(StoryGridItem item)? onTapItem;
  final int crossAxisCount;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (data.isLoading) {
      return const Center(child: SELoadingIndicator(size: SELoadingSize.large));
    }
    if (data.error != null) {
      return SEErrorWidget.fromError(data.error);
    }
    if (data.items.isEmpty) {
      return SEEmptyState(
        icon: Icons.menu_book,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7, // portada mas alta que ancha
      ),
      itemCount: data.items.length,
      itemBuilder: (context, index) {
        final item = data.items[index];
        return _StoryCard(item: item, onTap: () => onTapItem?.call(item));
      },
    );
  }
}

/// Card individual de un cuento (placeholder).
class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.item, required this.onTap});
  final StoryGridItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: SEColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: SEColors.primaryLight,
                child: Image.network(
                  item.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const Icon(
                    Icons.menu_book,
                    size: 48,
                    color: SEColors.primary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule,
                          size: 12, color: SEColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${item.durationMinutes} min',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SEColors.textHint,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
