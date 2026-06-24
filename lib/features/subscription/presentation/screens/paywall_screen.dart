import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../../domain/entities/subscription.dart';
import '../controllers/subscription_controller.dart';

/// Pantalla de paywall: muestra los planes y permite suscribirse.
///
/// Se muestra cuando:
/// - Usuario free toca feature bloqueada (hard paywall)
/// - Usuario free termina de leer cuentos gratis del mes (soft upsell)
/// - Usuario entra manualmente desde Settings
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({
    super.key,
    this.trigger = 'manual',
  });

  /// Qué triggered el paywall. Para analytics.
  /// 'manual' | 'feature_locked' | 'free_quota_reached' | 'story_end'
  final String trigger;

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  SubscriptionPlan? _selectedPlan = SubscriptionPlan.annual;
  bool _startTrial = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionControllerProvider);
    final controller = ref.read(subscriptionControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: state.isPurchasing
            ? _buildPurchasing(context)
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    // Hero
                    Icon(
                      Icons.auto_stories,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'StoryEnglish Premium',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Desbloqueá todos los cuentos, audio en español, descargas offline y más.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),

                    const SizedBox(height: 32),

                    // Lista de beneficios
                    _buildBenefitsList(context),

                    const SizedBox(height: 32),

                    // Selector de plan
                    _buildPlanSelector(context),

                    const SizedBox(height: 24),

                    // Trial toggle
                    if (_startTrial)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Empezás con 7 días gratis. '
                                'Podés cancelar cuando quieras antes de que termine.',
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Error
                    if (state.failure != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .errorContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          state.failure!.message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),

                    // CTA principal
                    SEButton(
                      onPressed: _selectedPlan == null
                          ? null
                          : () async {
                              final success = await controller.purchase(
                                _selectedPlan!,
                                startTrial: _startTrial,
                              );
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        '¡Premium activado! Disfrutá todos los cuentos.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                context.pop();
                              }
                            },
                      label: _startTrial
                          ? 'Empezar 7 días gratis'
                          : 'Suscribirme',
                      size: SEButtonSize.large,
                    ),

                    const SizedBox(height: 16),

                    // Restore + términos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await controller.restore();
                          },
                          child: const Text('Restaurar compras'),
                        ),
                        const Text('·'),
                        TextButton(
                          onPressed: () => context.push(Routes.terms),
                          child: const Text('Términos'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El cobro se realiza a través de tu cuenta de Google Play o App Store. '
                      'Se renueva automáticamente salvo que canceles.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context) {
    const benefits = [
      ('📚', 'Cuentos ilimitados', 'Acceso a todo el catálogo'),
      ('🎧', 'Audio en español', 'Narración premium en ambos idiomas'),
      ('💾', 'Descarga offline', 'Hasta 50 cuentos sin conexión'),
      ('👨‍👩‍👧', '4 perfiles de niños', 'Hasta 4 perfiles por cuenta'),
      ('📊', 'Panel padres avanzado', 'Reportes detallados y predicciones'),
      ('🏆', 'Logros completos', '30+ insignias para desbloquear'),
    ];

    return Column(
      children: benefits.map((b) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(b.$1, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.$2,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      b.$3,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlanSelector(BuildContext context) {
    return Column(
      children: SubscriptionPlan.values.map((plan) {
        final isSelected = _selectedPlan == plan;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedPlan = plan;
                if (plan == SubscriptionPlan.monthly) {
                  _startTrial = false; // trial solo en anual
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (plan == SubscriptionPlan.annual) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Ahorrá ${plan.savings.round()}%',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan == SubscriptionPlan.annual
                              ? '\$${plan.priceUsd.toStringAsFixed(2)}/año (\$${(plan.priceUsd / 12).toStringAsFixed(2)}/mes)'
                              : '\$${plan.priceUsd.toStringAsFixed(2)}/mes',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPurchasing(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Procesando tu suscripción...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'No cierres la app.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
