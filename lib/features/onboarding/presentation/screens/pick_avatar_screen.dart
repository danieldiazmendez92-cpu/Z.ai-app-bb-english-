import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../controllers/onboarding_controller.dart';

/// Pantalla para elegir el avatar del niño.
///
/// Muestra un grid de 10 avatares predefinidos (emojis de animales).
/// En producción se reemplazarían por imágenes custom.
class PickAvatarScreen extends ConsumerWidget {
  const PickAvatarScreen({super.key});

  static const List<Map<String, String>> _avatars = [
    {'emoji': '🐻', 'name': 'Oso'},
    {'emoji': '🦊', 'name': 'Zorro'},
    {'emoji': '🐰', 'name': 'Conejo'},
    {'emoji': '🦁', 'name': 'León'},
    {'emoji': '🐯', 'name': 'Tigre'},
    {'emoji': '🐱', 'name': 'Gato'},
    {'emoji': '🐶', 'name': 'Perro'},
    {'emoji': '🦉', 'name': 'Búho'},
    {'emoji': '🐼', 'name': 'Panda'},
    {'emoji': '🦄', 'name': 'Unicornio'},
  ];

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elegí un avatar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('${Routes.onboarding}/welcome'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '¿Cómo se va a ver tu hijo?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Elegí un personaje que le guste.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = _avatars[index];
                    final isSelected = state.avatarUrl == avatar['emoji'];

                    return GestureDetector(
                      onTap: () {
                        controller.setAvatar(avatar['emoji']!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.15)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                avatar['emoji']!,
                                style: const TextStyle(fontSize: 56),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(
                                  Icons.check_circle,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  size: 24,
                                ),
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
                onPressed: state.avatarUrl == null
                    ? null
                    : () => context.go('${Routes.onboarding}/age'),
                label: 'Siguiente',
                size: SEButtonSize.large,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
