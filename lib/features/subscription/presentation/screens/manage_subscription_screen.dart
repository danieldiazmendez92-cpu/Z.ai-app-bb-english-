import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../../domain/entities/subscription.dart';
import '../controllers/subscription_controller.dart';

/// Pantalla para gestionar la suscripción activa.
///
/// Muestra:
/// - Estado actual (activo/cancelado/trial)
/// - Plan, fecha de renovación, precio
/// - Botón "Gestionar en Google Play / App Store"
/// - Botón "Cambiar plan"
/// - Botón "Cancelar suscripción" (link a store nativa)
class ManageSubscriptionScreen extends ConsumerWidget {
  const ManageSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(subscriptionControllerProvider);
    final sub = state.subscription;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi suscripción'),
      ),
      body: SafeArea(
        child: sub == null
            ? _buildNoSubscription(context, ref)
            : _buildActiveSubscription(context, ref, sub),
      ),
    );
  }

  Widget _buildNoSubscription(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No tenés Premium',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Suscribite para desbloquear todos los cuentos, audio en español y descargas offline.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            SEButton(
              onPressed: () => context.push(Routes.paywall),
              label: 'Ver planes',
              size: SEButtonSize.large,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await ref.read(subscriptionControllerProvider.notifier).restore();
              },
              child: const Text('Restaurar compras'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveSubscription(
    BuildContext context,
    WidgetRef ref,
    Subscription sub,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Estado
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Icon(
                sub.isActive ? Icons.verified : Icons.warning,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                sub.isActive ? 'Premium Activo' : 'Suscripción inactiva',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              if (sub.isTrial) ...[
                const SizedBox(height: 4),
                Text(
                  'Período de prueba',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Detalles
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              _detailRow(context, 'Plan', _planName(sub.plan)),
              _detailRow(context, 'Plataforma',
                  sub.platform == 'android' ? 'Google Play' : 'App Store'),
              _detailRow(
                  context, 'Renueva el', _formatDate(sub.expiresAt)),
              _detailRow(
                context,
                'Auto renovación',
                sub.autoRenew ? 'Activada' : 'Desactivada',
              ),
              if (sub.isTrial && sub.trialEndsAt != null)
                _detailRow(context, 'Trial termina',
                    _formatDate(sub.trialEndsAt!)),
              _detailRow(
                context,
                'Días restantes',
                '${sub.daysRemaining}',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Acciones
        SEButton(
          onPressed: () => _openStoreSubscriptionManagement(context, sub),
          label: sub.platform == 'android'
              ? 'Gestionar en Google Play'
              : 'Gestionar en App Store',
          icon: Icons.open_in_new,
          size: SEButtonSize.large,
        ),

        const SizedBox(height: 12),

        if (sub.isActive && sub.autoRenew)
          OutlinedButton.icon(
            onPressed: () => _showCancelInfo(context, sub),
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancelar suscripción'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

        const SizedBox(height: 24),

        // FAQ
        Text(
          'Preguntas frecuentes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _faqItem(
          context,
          '¿Puedo usar la app después de cancelar?',
          'Sí, hasta que expire tu período ya pago. Después, '
          'pasás a la versión gratuita con cuentos limitados.',
        ),
        _faqItem(
          context,
          '¿Cómo obtengo reembolso?',
          'Los reembolsos se gestionan directamente con Google Play '
          'o App Store según su política.',
        ),
        _faqItem(
          context,
          '¿Puedo cambiar de plan?',
          'Sí. Si pasás de mensual a anual, el cambio se aplica al '
          'final del período actual.',
        ),
      ],
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _faqItem(BuildContext context, String q, String a) {
    return ExpansionTile(
      title: Text(q),
      tilePadding: EdgeInsets.zero,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            a,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  String _planName(String plan) {
    return plan == 'annual' ? 'Anual' : 'Mensual';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _openStoreSubscriptionManagement(
      BuildContext context, Subscription sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestionar suscripción'),
        content: Text(
          sub.platform == 'android'
              ? 'Para gestionar tu suscripción, abrí Google Play Store → '
                  'Toca tu perfil → Pagos y suscripciones → Suscripciones.'
              : 'Para gestionar tu suscripción, abrí la app Settings → '
                  'Apple ID → Suscripciones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showCancelInfo(BuildContext context, Subscription sub) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar suscripción'),
        content: Text(
          'Para cancelar tu suscripción, necesitas hacerlo directamente '
          'desde ${sub.platform == 'android' ? "Google Play Store" : "App Store"}. '
          '\n\nMantendrás acceso Premium hasta el ${_formatDate(sub.expiresAt)}, '
          'después pasarás a la versión gratuita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openStoreSubscriptionManagement(context, sub);
            },
            child: const Text('Ir a la tienda'),
          ),
        ],
      ),
    );
  }
}
