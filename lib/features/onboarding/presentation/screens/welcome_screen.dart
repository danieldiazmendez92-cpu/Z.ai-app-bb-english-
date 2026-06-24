import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../controllers/onboarding_controller.dart';

/// Pantalla de bienvenida del onboarding.
///
/// Se muestra después del signup/login + parental verification.
/// Da la bienvenida al padre y explica brevemente qué va a hacer.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Animación / icono grande
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
                  Icons.waving_hand,
                  size: 120,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                '¡Hola!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),

              const SizedBox(height: 16),

              Text(
                'Vamos a configurar el perfil de tu hijo para que empiece a aprender inglés con cuentos increíbles.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),

              const Spacer(),

              SEButton(
                onPressed: () {
                  ref
                      .read(onboardingControllerProvider.notifier)
                      .startOnboarding();
                  context.go('${Routes.onboarding}/avatar');
                },
                label: 'Empezar',
                size: SEButtonSize.large,
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('Hacerlo después'),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
