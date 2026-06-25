import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/story_section.dart';
import '../controllers/reader_controller.dart';

/// Variante del Reader para niños de 2-4 años (pre-lectores).
///
/// Diferencias con ReaderScreen normal:
/// - NO muestra texto (solo ilustración grande)
/// - Audio reproduce automáticamente al entrar
/// - Controles simplificados (solo play/pause grande)
/// - Botones grandes (mín 72dp)
/// - Navegación entre secciones con flechas grandes
///
/// Se activa automáticamente cuando el niño activo tiene edad <= 3.
class ReadToMeScreen extends ConsumerWidget {
  const ReadToMeScreen({
    super.key,
    required this.storyId,
  });

  final String storyId;

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(readerControllerProvider(storyId));
    final controller = ref.read(readerControllerProvider(storyId).notifier);

    if (state.isLoading) {
      return Scaffold(
        body: const Center(child: CircularProgressIndicator()),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
      );
    }

    if (state.sections.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Este cuento no tiene contenido.'),
        ),
      );
    }

    final section = state.sections[state.currentSectionIndex];
    final isLastSection =
        state.currentSectionIndex == state.sections.length - 1;

    // Auto-play al entrar (si no está reproduciéndose ya)
    if (!state.isPlaying && state.positionMs == 0) {
      Future.microtask(() => controller.play());
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar minimal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 32),
                    ),
                  ),
                  const Spacer(),
                  // Indicador de páginas (puntos)
                  Row(
                    children: List.generate(
                      state.sections.length,
                      (i) => Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == state.currentSectionIndex
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 56), // Balancear
                ],
              ),
            ),

            // Ilustración grande (centro)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Center(
                    child: Text(
                      section.illustrationUrl ?? '📖',
                      style: const TextStyle(fontSize: 180),
                    ),
                  ),
                ),
              ),
            ),

            // Indicador de audio (ondas animadas cuando suena)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.isPlaying)
                    Row(
                      children: List.generate(
                        5,
                        (i) => Container(
                          width: 8,
                          height: 8 + (i % 3) * 12.0,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )
                  else
                    const Text('🔊 Tocá para escuchar'),
                ],
              ),
            ),

            // Controles grandes
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Anterior
                  GestureDetector(
                    onTap: state.currentSectionIndex > 0
                        ? controller.previousSection
                        : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: state.currentSectionIndex > 0
                            ? Theme.of(context).colorScheme.surfaceVariant
                            : Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.skip_previous,
                        size: 48,
                        color: state.currentSectionIndex > 0
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                      ),
                    ),
                  ),

                  // Play/Pause gigante
                  GestureDetector(
                    onTap: controller.togglePlayPause,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 72,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),

                  // Siguiente
                  GestureDetector(
                    onTap: !isLastSection
                        ? controller.nextSection
                        : () => context.pop(),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: !isLastSection
                            ? Theme.of(context).colorScheme.surfaceVariant
                            : Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLastSection ? Icons.check : Icons.skip_next,
                        size: 48,
                        color: isLastSection
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
