import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../controllers/onboarding_controller.dart';

/// Pantalla para elegir los intereses del niño.
///
/// Muestra una grilla de chips multiselect. El niño/padre puede elegir
/// tantos intereses como quiera (mínimo 1).
class PickInterestsScreen extends ConsumerWidget {
  const PickInterestsScreen({super.key});

  static const List<Map<String, String>> _interests = [
    {'id': 'animals', 'label': 'Animales', 'emoji': '🐶'},
    {'id': 'adventure', 'label': 'Aventuras', 'emoji': '🚀'},
    {'id': 'bedtime', 'label': 'Hora de dormir', 'emoji': '🌙'},
    {'id': 'fairy', 'label': 'Cuentos de hadas', 'emoji': '🧚'},
    {'id': 'learning', 'label': 'Aprender', 'emoji': '📚'},
    {'id': 'music', 'label': 'Música', 'emoji': '🎵'},
    {'id': 'nature', 'label': 'Naturaleza', 'emoji': '🌳'},
    {'id': 'friends', 'label': 'Amigos', 'emoji': '🤝'},
  ];

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Qué le gusta?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('${Routes.onboarding}/age'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Elegí al menos un interés. Vamos a recomendar cuentos según esto.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _interests.length,
                  itemBuilder: (context, index) {
                    final interest = _interests[index];
                    final isSelected =
                        state.interests.contains(interest['id']);

                    return GestureDetector(
                      onTap: () {
                        controller.toggleInterest(interest['id']!);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.15)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              interest['emoji']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                interest['label']!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color:
                                    Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              SEButton(
                onPressed: state.interests.isEmpty
                    ? null
                    : () async {
                        final success = await controller.finish();
                        if (success && context.mounted) {
                          context.go(Routes.home);
                        }
                      },
                label: '¡Listo! Crear perfil',
                isLoading: state.isCreating,
                size: SEButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
