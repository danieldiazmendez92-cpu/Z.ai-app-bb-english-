import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../../../../core/widgets/se_text_field.dart';
import 'controllers/parental_verification_controller.dart';

/// Pantalla de verificación parental.
///
/// Para cumplir con COPPA, antes de crear perfiles de niño,
/// el padre debe verificar que es adulto. En esta implementación
/// usamos 3 preguntas matemáticas simples (método aceptado por FTC).
///
/// El flujo es:
/// 1. Pantalla inicial → botón "Verificar que soy adulto"
/// 2. Genera 3 preguntas matemáticas (vía Cloud Function `verifyParental`)
/// 3. El usuario responde
/// 4. Si 3/3 correctas → marcado como verificado → navega a onboarding
/// 5. Si falla → puede reintentar (rate limit: 3 intentos/hora)
class ParentalVerificationScreen extends ConsumerStatefulWidget {
  const ParentalVerificationScreen({super.key});

  @override
  ConsumerState<ParentalVerificationScreen> createState() =>
      _ParentalVerificationScreenState();
}

class _ParentalVerificationScreenState
    extends ConsumerState<ParentalVerificationScreen> {
  final List<TextEditingController> _answerControllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _answerControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parentalVerificationControllerProvider);
    final controller =
        ref.read(parentalVerificationControllerProvider.notifier);

    ref.listen<ParentalVerificationState>(
      parentalVerificationControllerProvider,
      (previous, next) {
        if (next.status == ParentalVerificationStatus.verified) {
          // Éxito: navegar a onboarding
          context.go(Routes.onboarding);
        } else if (next.failure != null &&
            next.status == ParentalVerificationStatus.error) {
          _showError(next.failure!.message);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificación de adulto'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(state, controller),
        ),
      ),
    );
  }

  Widget _buildContent(
    ParentalVerificationState state,
    ParentalVerificationController controller,
  ) {
    switch (state.status) {
      case ParentalVerificationStatus.idle:
        return _buildIntro(controller);

      case ParentalVerificationStatus.generatingChallenge:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Preparando preguntas...'),
            ],
          ),
        );

      case ParentalVerificationStatus.challengeReady:
      case ParentalVerificationStatus.verifying:
        return _buildChallenge(state, controller);

      case ParentalVerificationStatus.verified:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 80, color: Colors.green),
              SizedBox(height: 16),
              Text('¡Verificación exitosa!'),
            ],
          ),
        );

      case ParentalVerificationStatus.error:
        return _buildError(state, controller);
    }
  }

  Widget _buildIntro(ParentalVerificationController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(
          Icons.family_restroom,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          'Para crear perfiles de tu hijo',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Necesitamos verificar que sos un adulto. Te vamos a pedir que respondas 3 preguntas matemáticas simples.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        SEButton(
          onPressed: controller.generateChallenge,
          label: 'Verificar que soy adulto',
          size: SEButtonSize.large,
        ),
        const SizedBox(height: 16),
        Text(
          'Esto es obligatorio para cumplir con leyes de protección de menores (COPPA y GDPR-K).',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildChallenge(
    ParentalVerificationState state,
    ParentalVerificationController controller,
  ) {
    final challenge = state.challenge;
    if (challenge == null) {
      return const Center(child: Text('Error: no hay preguntas cargadas'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Respondé las preguntas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Para confirmar que sos un adulto.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 32),

        Expanded(
          child: ListView.builder(
            itemCount: challenge.questions.length,
            itemBuilder: (context, index) {
              final question = challenge.questions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pregunta ${index + 1} de ${challenge.questions.length}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question['question'] as String,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    SETextField(
                      controller: _answerControllers[index],
                      label: 'Tu respuesta',
                      keyboardType: TextInputType.number,
                      enabled: state.status !=
                          ParentalVerificationStatus.verifying,
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        SEButton(
          onPressed: state.status == ParentalVerificationStatus.verifying
              ? null
              : () => _submitAnswers(controller),
          label: 'Verificar',
          isLoading: state.status == ParentalVerificationStatus.verifying,
          size: SEButtonSize.large,
        ),
      ],
    );
  }

  Widget _buildError(
    ParentalVerificationState state,
    ParentalVerificationController controller,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            state.failure?.message ?? 'Error desconocido',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          SEButton(
            onPressed: () {
              controller.reset();
              controller.generateChallenge();
            },
            label: 'Intentar de nuevo',
            size: SEButtonSize.large,
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswers(ParentalVerificationController controller) async {
    final answers = _answerControllers
        .map((c) => int.tryParse(c.text.trim()) ?? -1)
        .toList();

    await controller.submitAnswers(answers);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
