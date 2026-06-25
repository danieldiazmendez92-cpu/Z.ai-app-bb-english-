import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_error_widget.dart';
import '../../../child_profile/presentation/controllers/child_profile_controller.dart';
import '../../../story/domain/entities/story.dart';
import '../../../vocabulary/presentation/controllers/vocabulary_review_controller.dart';
import '../../presentation/controllers/home_controller.dart';
import '../../../library/presentation/widgets/story_card.dart';

/// Pantalla principal: cuentos recomendados + continuar leyendo.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(homeControllerProvider);
    final controller = ref.read(homeControllerProvider.notifier);
    final activeChild = ref.watch(activeChildProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (activeChild != null) ...[
              Text(
                activeChild.avatarUrl,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, ${activeChild.name}!',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      '${activeChild.age} años',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Continuar leyendo
              if (activeChild != null) ...[
                _sectionTitle(context, 'Continuar leyendo'),
                const SizedBox(height: 8),
                SizedBox(
                  height: 140,
                  child: state.continueReading.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => SEErrorWidget(
                      message: e.toString(),
                      onRetry: controller.refresh,
                    ),
                    data: (progress) {
                      if (progress.isEmpty) {
                        return _emptyContinueReading(context);
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: progress.length,
                        itemBuilder: (context, index) {
                          final p = progress[index];
                          return Padding(
                            padding: EdgeInsets.only(
                              right: 12,
                              left: index == 0 ? 0 : 0,
                            ),
                            child: _ContinueReadingCard(progress: p),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recomendados
              _sectionTitle(context, 'Recomendados para vos'),
              const SizedBox(height: 8),
              state.recommended.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => SEErrorWidget(
                  message: e.toString(),
                  onRetry: controller.refresh,
                ),
                data: (stories) {
                  if (stories.isEmpty) {
                    return _emptyRecommended(context);
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: stories.length,
                    itemBuilder: (context, index) {
                      return StoryCard(story: stories[index]);
                    },
                  );
                },
              ),

              // Link a biblioteca
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => context.go(Routes.library),
                icon: const Icon(Icons.menu_book),
                label: const Text('Ver todos los cuentos'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // Botón de repaso de vocabulario (SRS)
              const SizedBox(height: 12),
              _VocabularyReviewButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _emptyContinueReading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'Empezá a leer un cuento',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _emptyRecommended(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.auto_stories,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay cuentos todavía',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estamos cargando nuevos cuentos. ¡Volvé pronto!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card horizontal para "Continuar leyendo".
class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({required this.progress});

  final dynamic progress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.readerFor(progress.storyId as String)),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  progress.storyCoverUrl as String? ?? '📖',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    progress.storyTitle as String? ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (progress.completionPct as int? ?? 0) / 100,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${progress.completionPct ?? 0}% completado',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Botón que muestra cuántas palabras hay para repasar y navega al SRS.
/// Solo se muestra si hay palabras due.
class _VocabularyReviewButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ref) {
    final dueCount = ref.watch(dueWordsCountProvider).valueOrNull ?? 0;

    if (dueCount == 0) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.tertiary ?? Theme.of(context).colorScheme.primary,
            (Theme.of(context).colorScheme.tertiary ?? Theme.of(context).colorScheme.primary)
                .withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(Routes.vocabularyReview),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('🔤', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Repasar palabras',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$dueCount palabra${dueCount == 1 ? '' : 's'} para repasar',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
