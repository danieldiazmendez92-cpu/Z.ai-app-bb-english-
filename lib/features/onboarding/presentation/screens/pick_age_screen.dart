import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../controllers/onboarding_controller.dart';

/// Pantalla para elegir la edad del niño (2-7 años).
class PickAgeScreen extends ConsumerWidget {
  const PickAgeScreen({super.key});

  static const List<Map<String, dynamic>> _ages = [
    {'age': 2, 'label': '2 años', 'emoji': '👶', 'desc': 'Toddler'},
    {'age': 3, 'label': '3 años', 'emoji': '🧒', 'desc': 'Pre-K'},
    {'age': 4, 'label': '4 años', 'emoji': '👦', 'desc': 'Pre-K'},
    {'age': 5, 'label': '5 años', 'emoji': '🧑', 'desc': 'Kindergarten'},
    {'age': 6, 'label': '6 años', 'emoji': '📚', 'desc': '1st grade'},
    {'age': 7, 'label': '7 años', 'emoji': '🎓', 'desc': '2nd grade'},
  ];

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('¿Qué edad tiene?'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('${Routes.onboarding}/avatar'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Así podemos recomendarte cuentos adecuados.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  itemCount: _ages.length,
                  itemBuilder: (context, index) {
                    final item = _ages[index];
                    final age = item['age'] as int;
                    final isSelected = state.age == age;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => controller.setAge(age),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
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
                                item['emoji'] as String,
                                style: const TextStyle(fontSize: 40),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['label'] as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      item['desc'] as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
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
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              SEButton(
                onPressed: state.age == null
                    ? null
                    : () => context.go('${Routes.onboarding}/interests'),
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
