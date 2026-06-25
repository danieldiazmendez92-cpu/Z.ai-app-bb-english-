import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../../domain/entities/comprehension_question.dart';
import '../controllers/reader_controller.dart';

/// Pantalla final del cuento.
///
/// Muestra:
/// - Felicitación por terminar el cuento
/// - Pregunta de comprensión (generada por Gemini)
/// - Animación de logro (si desbloqueó uno)
/// - Botones: volver al home, leer otro cuento
class StoryEndScreen extends ConsumerStatefulWidget {
  const StoryEndScreen({
    super.key,
    required this.storyId,
  });

  final String storyId;

  @override
  ConsumerState<StoryEndScreen> createState() => _StoryEndScreenState();
}

class _StoryEndScreenState extends ConsumerState<StoryEndScreen> {
  int? _selectedAnswer;
  bool _answered = false;
  // CORRECCIÓN PEDAGÓGICA: contador de intentos para permitir reintentos
  int _attempts = 0;
  static const int _maxAttempts = 2;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerControllerProvider(widget.storyId));
    final questions = state.questions;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Icono de celebración
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Icon(
                  Icons.celebration,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                '¡Felicitaciones!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),

              const SizedBox(height: 8),

              Text(
                'Terminaste "${state.story?.title ?? ''}"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 32),

              // Pregunta de comprensión (si hay)
              if (questions.isNotEmpty) ...[
                _buildComprehensionQuestion(
                    context, questions.first),
                const SizedBox(height: 32),
              ],

              // Botones de acción
              SEButton(
                onPressed: () => context.go(Routes.home),
                label: 'Volver al inicio',
                icon: Icons.home,
                size: SEButtonSize.large,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go(Routes.library),
                icon: const Icon(Icons.menu_book),
                label: const Text('Leer otro cuento'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComprehensionQuestion(
      BuildContext context, ComprehensionQuestion question) {
    final isCorrect = _answered && _selectedAnswer == question.correctIndex;
    final canRetry = _answered && !isCorrect && _attempts < _maxAttempts;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.quiz,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Pregunta de comprensión',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.questionText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < question.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AnswerOption(
                text: question.options[i],
                isSelected: _selectedAnswer == i,
                isCorrect: _answered && i == question.correctIndex,
                isWrong: _answered &&
                    _selectedAnswer == i &&
                    i != question.correctIndex,
                onTap: (_answered && !canRetry)
                    ? null
                    : () => _selectAnswer(i, question),
              ),
            ),

          if (_answered && !isCorrect && !canRetry) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¡Casi! La respuesta era: ${question.options[question.correctIndex]}. ${question.explanation}',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (canRetry) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.refresh,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¡Sigamos intentando! Podés volver a probar.',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Intentar de nuevo'),
              ),
            ),
          ] else if (isCorrect) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '¡Muy bien! Respondiste correctamente. 🎉',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _selectAnswer(int index, ComprehensionQuestion question) {
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _attempts++;
    });
  }

  void _retry() {
    setState(() {
      _selectedAnswer = null;
      _answered = false;
    });
  }
}

/// Widget de opción de respuesta con feedback no punitivo.
/// CORRECCIÓN PEDAGÓGICA:
/// - Eliminado el color rojo y el icono de cancel (cruz roja)
/// - Reemplazados por un tono suave (amarillo/naranja) + icono de "casi"
class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color? borderColor;
    Color? textColor;

    if (isCorrect) {
      bgColor = Colors.green.withOpacity(0.1);
      borderColor = Colors.green;
      textColor = Colors.green.shade700;
    } else if (isWrong) {
      // CORRECCIÓN: era Colors.red, ahora amarillo suave (no punitivo)
      bgColor = Colors.amber.withOpacity(0.15);
      borderColor = Colors.amber.shade600;
      textColor = Colors.brown.shade700;
    } else if (isSelected) {
      bgColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      borderColor = Theme.of(context).colorScheme.primary;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor ??
                Theme.of(context).colorScheme.outlineVariant,
            width: isSelected || isCorrect || isWrong ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle, color: Colors.green)
            // CORRECCIÓN: era Icons.cancel (cruz roja), ahora icono neutro
            else if (isWrong)
              const Icon(Icons.help_outline, color: Colors.amber),
          ],
        ),
      ),
    );
  }
}
