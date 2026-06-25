import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/se_button.dart';
import '../../domain/services/srs_algorithm.dart';
import '../controllers/vocabulary_review_controller.dart';

/// Pantalla de repaso de vocabulario con flashcards.
///
/// Flujo:
/// 1. Muestra palabra en inglés (card frontal)
/// 2. Niño piensa la traducción
/// 3. Tap para voltear (muestra traducción)
/// 4. Niño evalúa si la sabía: "Sí, fácil" / "Sí, con esfuerzo" / "No"
/// 5. Siguiente palabra
///
/// Al terminar: resumen de repasadas + correctas + animación.
class VocabularyReviewScreen extends ConsumerWidget {
  const VocabularyReviewScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(vocabularyReviewControllerProvider);
    final controller = ref.read(vocabularyReviewControllerProvider.notifier);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Repasar palabras')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.failure != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Repasar palabras')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                Text(state.failure!.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.restart,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Pantalla de "no hay palabras due"
    if (state.dueWords.isEmpty) {
      return _buildEmpty(context, ref);
    }

    // Pantalla de "repaso completo"
    if (state.isComplete) {
      return _buildComplete(context, ref, state);
    }

    // Pantalla de flashcard
    return _buildFlashcard(context, ref, state, controller);
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repasar palabras'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌟', style: TextStyle(fontSize: 96)),
              const SizedBox(height: 24),
              Text(
                '¡No hay palabras para repasar!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Volvé más tarde o leé más cuentos para aprender palabras nuevas.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              SEButton(
                onPressed: () => context.pop(),
                label: 'Volver',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplete(BuildContext context, WidgetRef ref,
      VocabularyReviewState state) {
    final total = state.totalReviewed;
    final correct = state.correctCount;
    final pct = total > 0 ? (correct / total * 100).round() : 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Animación de celebración
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: Text(
                  pct >= 80 ? '🎉' : (pct >= 50 ? '⭐' : '📚'),
                  style: const TextStyle(fontSize: 120),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                '¡Repaso completo!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Repasaste $total palabras',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 32),

              // Stats del repaso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statCard(
                    context,
                    icon: '✅',
                    value: '$correct',
                    label: 'Correctas',
                    color: Colors.green,
                  ),
                  _statCard(
                    context,
                    icon: '📊',
                    value: '$pct%',
                    label: 'Aciertos',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  _statCard(
                    context,
                    icon: '📚',
                    value: '$total',
                    label: 'Repasadas',
                    color: Colors.amber,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SEButton(
                onPressed: () => context.pop(),
                label: '¡Genial!',
                size: SEButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context, {
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFlashcard(
    BuildContext context,
    WidgetRef ref,
    VocabularyReviewState state,
    VocabularyReviewController controller,
  ) {
    final word = state.currentWord!;

    return Scaffold(
      appBar: AppBar(
        title: Text('${state.currentIndex + 1} / ${state.dueWords.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _confirmExit(context, ref),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de progreso
            LinearProgressIndicator(
              value: state.dueWords.isEmpty
                  ? 0
                  : (state.currentIndex / state.dueWords.length),
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card flippeable
                    Expanded(
                      child: GestureDetector(
                        onTap: controller.flipCard,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, animation) {
                            final rotate = Tween<double>(
                              begin: 0,
                              end: 1,
                            ).animate(animation);
                            return Transform.rotate(
                              angle: rotate.value * 3.14,
                              child: child,
                            );
                          },
                          child: !state.isFlipped
                              ? _buildFrontCard(context, word)
                              : _buildBackCard(context, word),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botones de respuesta (solo cuando está volteada)
                    if (state.isFlipped) ...[
                      Text(
                        '¿La sabías?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _answerButton(
                              context,
                              label: 'No',
                              emoji: '😕',
                              color: Colors.amber,
                              onPressed: () => controller.answerQuality(
                                  ReviewQuality.incorrect),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _answerButton(
                              context,
                              label: 'Casi',
                              emoji: '🤔',
                              color: Colors.orange,
                              onPressed: () => controller.answerQuality(
                                  ReviewQuality.hard),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _answerButton(
                              context,
                              label: '¡Sí!',
                              emoji: '😊',
                              color: Colors.green,
                              onPressed: () => controller
                                  .answerQuality(ReviewQuality.good),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      SEButton(
                        onPressed: controller.flipCard,
                        label: 'Ver respuesta',
                        icon: Icons.flip,
                        size: SEButtonSize.large,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: controller.skipWord,
                        child: const Text('Saltar'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context, dynamic word) {
    return Container(
      key: const ValueKey('front'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            word.wordEn as String,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          if (word.phonetic != null) ...[
            const SizedBox(height: 12),
            Text(
              word.phonetic as String,
              style: TextStyle(
                fontSize: 20,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 32),
          Icon(
            Icons.touch_app,
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Tocá para ver la traducción',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(BuildContext context, dynamic word) {
    return Container(
      key: const ValueKey('back'),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            word.wordEn as String,
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.wordEs as String,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          if (word.exampleSentence != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${word.exampleSentence}"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _answerButton(
    BuildContext context, {
    required String label,
    required String emoji,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmExit(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir del repaso?'),
        content: const Text(
          'Tu progreso se guarda. Podés continuar más tarde.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Seguir'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
