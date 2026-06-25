import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../shared/providers/child_profile_provider.dart';
import '../../../vocabulary/presentation/controllers/vocabulary_review_controller.dart';
import '../../domain/entities/story_section.dart';
import '../../domain/entities/vocabulary_word.dart';
import '../controllers/reader_controller.dart';
import '../widgets/highlighted_text.dart';
import '../widgets/interactive_illustration.dart';
import '../widgets/vocabulary_popup.dart';

/// Pantalla de lectura del cuento.
///
/// Muestra:
/// - Texto del cuento en inglés (con resaltado sincronizado al audio)
/// - Traducción al español (toggleable)
/// - Controles de audio (play/pause/seek/speed)
/// - Ilustración de la escena actual
/// - Navegación entre secciones
///
/// Al terminar el audio, navega a StoryEndScreen.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({
    super.key,
    required this.storyId,
  });

  final String storyId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _showTranslation = false;
  VocabularyWord? _popupWord;

  @override
  void dispose() {
    // El controller se dispone automáticamente por Riverpod
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerControllerProvider(widget.storyId));
    final controller =
        ref.read(readerControllerProvider(widget.storyId).notifier);

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.failure != null) {
      return Scaffold(
        appBar: AppBar(),
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
                  onPressed: () => context.pop(),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state.sections.isEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Este cuento no tiene contenido todavía.')),
      );
    }

    final section = state.sections[state.currentSectionIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _showExitConfirmation(context);
                    },
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: state.durationMs > 0
                          ? state.positionMs / state.durationMs
                          : 0,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _showTranslation
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _showTranslation = !_showTranslation;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ilustración interactiva con hotspots
                    Center(
                      child: InteractiveIllustration(
                        storyId: widget.storyId,
                        sectionOrder: section.order,
                        size: 220,
                        showHints: true,
                        onWordTap: (word, translation) {
                          // Mostrar popup con la palabra
                          _showHotspotPopup(context, word, translation);
                          // Reproducir palabra (TTS o audio pre-grabado)
                          // En demo mode, mostramos snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🔊 $word = $translation'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Texto en inglés con resaltado
                    HighlightedText(
                      text: section.textEn,
                      highlightIndex: state.currentWordIndex,
                      highlightedWordIndices: _findVocabIndices(
                        section.textEn,
                        state.vocabulary,
                      ),
                      onWordTap: (word, _) {
                        final vocab = controller.findVocabularyWord(word);
                        if (vocab != null) {
                          setState(() {
                            _popupWord = vocab;
                          });
                          // CORRECCIÓN PEDAGÓGICA: registrar palabra vista
                          // en el sistema SRS para repaso espaciado.
                          _recordWordSeen(vocab);
                        }
                      },
                    ),

                    // Traducción (toggleable)
                    if (_showTranslation) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          section.textEs,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Navegación entre secciones
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (state.currentSectionIndex > 0)
                          TextButton.icon(
                            onPressed: controller.previousSection,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Anterior'),
                          )
                        else
                          const SizedBox(width: 0),
                        Text(
                          '${state.currentSectionIndex + 1} / ${state.sections.length}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (state.currentSectionIndex <
                            state.sections.length - 1)
                          TextButton.icon(
                            onPressed: controller.nextSection,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Siguiente'),
                          )
                        else
                          TextButton.icon(
                            onPressed: () => context.go(
                                Routes.storyEndFor(widget.storyId)),
                            icon: const Icon(Icons.check),
                            label: const Text('Finalizar'),
                          ),
                      ],
                    ),

                    const SizedBox(height: 100), // Espacio para controls
                  ],
                ),
              ),
            ),

            // Controles de audio (fixed bottom)
            _AudioControls(
              isPlaying: state.isPlaying,
              positionMs: state.positionMs,
              durationMs: state.durationMs,
              speed: state.speed,
              onPlayPause: controller.togglePlayPause,
              onSeek: controller.seekToMs,
              onRewind: controller.rewind10s,
              onForward: controller.forward10s,
              onSpeedChange: controller.setSpeed,
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra un popup cuando el niño toca un hotspot en la ilustración.
  void _showHotspotPopup(
      BuildContext context, String word, String translation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              translation,
              style: TextStyle(
                fontSize: 24,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.volume_up,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('¡Entendido!'),
          ),
        ],
      ),
    );
  }

  /// Registra que el niño vio una palabra de vocabulario (para SRS).
  /// Se llama cuando se abre el VocabularyPopup.
  void _recordWordSeen(VocabularyWord vocab) {
    final activeChild = ref.read(activeChildProvider);
    if (activeChild == null) return;

    // Fire-and-forget: no bloqueamos la UI esperando el resultado.
    ref.read(learnedWordsRepositoryProvider).recordWordSeen(
          childId: activeChild.childId,
          wordEn: vocab.wordEn,
          wordEs: vocab.wordEs,
          phonetic: vocab.phonetic,
          exampleSentence: vocab.exampleSentence,
          sourceStoryId: widget.storyId,
        );
  }

  /// Encuentra los índices de las palabras del texto que son vocabulario.
  Set<int> _findVocabIndices(
      String text, List<VocabularyWord> vocabulary) {
    final words = text.split(RegExp(r'\s+'));
    final vocabWords = vocabulary
        .where((v) => v.isHighlighted)
        .map((v) => v.wordEn.toLowerCase())
        .toSet();

    final indices = <int>{};
    for (var i = 0; i < words.length; i++) {
      final cleaned = words[i].toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
      if (vocabWords.contains(cleaned)) {
        indices.add(i);
      }
    }
    return indices;
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir del cuento?'),
        content: const Text(
          'Tu progreso se guarda automáticamente. '
          'Podés continuar donde lo dejaste más tarde.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Seguir leyendo'),
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

/// Controles de audio固定 en la parte inferior del Reader.
class _AudioControls extends StatelessWidget {
  const _AudioControls({
    required this.isPlaying,
    required this.positionMs,
    required this.durationMs,
    required this.speed,
    required this.onPlayPause,
    required this.onSeek,
    required this.onRewind,
    required this.onForward,
    required this.onSpeedChange,
  });

  final bool isPlaying;
  final int positionMs;
  final int durationMs;
  final double speed;
  final VoidCallback onPlayPause;
  final ValueChanged<int> onSeek;
  final VoidCallback onRewind;
  final VoidCallback onForward;
  final ValueChanged<double> onSpeedChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider de posición
          Row(
            children: [
              Text(_formatTime(positionMs)),
              Expanded(
                child: Slider(
                  value: positionMs.toDouble().clamp(0, durationMs.toDouble()),
                  max: durationMs.toDouble(),
                  onChanged: durationMs > 0 ? onSeek : null,
                ),
              ),
              Text(_formatTime(durationMs)),
            ],
          ),

          // Botones de control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                onPressed: onRewind,
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 40,
                  ),
                  onPressed: onPlayPause,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 32,
                onPressed: onForward,
              ),
            ],
          ),

          // Velocidad
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final s in [0.75, 1.0, 1.25, 1.5])
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('${s}x'),
                    selected: speed == s,
                    onSelected: (_) => onSpeedChange(s),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(int ms) {
    final minutes = (ms / 60000).floor();
    final seconds = ((ms % 60000) / 1000).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
