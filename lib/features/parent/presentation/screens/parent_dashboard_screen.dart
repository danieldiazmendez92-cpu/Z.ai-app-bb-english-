import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../child_profile/domain/entities/parental_settings.dart';
import '../../../progress/domain/entities/reading_stats.dart';
import '../controllers/parent_dashboard_controller.dart';
import '../widgets/usage_chart.dart';

/// Pantalla principal del panel de padres.
///
/// Muestra:
/// - Stats de uso del niño activo (cuentos, minutos, racha)
/// - Gráfico de uso semanal (bar chart)
/// - Accesos rápidos a: controles parentales, reportes, suscripción
///
/// Requiere PIN verificado (vía [ParentPinScreen]).
class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(parentDashboardControllerProvider);

    // Si no verificó PIN, mostrar pantalla de PIN
    if (!state.isPinVerified) {
      return const ParentPinScreen();
    }

    final stats = state.stats.valueOrNull ?? const ReadingStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de padres'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(parentDashboardControllerProvider.notifier).refresh(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'controls':
                  context.push(Routes.parentalControls);
                  break;
                case 'subscription':
                  context.push(Routes.subscription);
                  break;
                case 'logout':
                  _confirmLogout(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'controls',
                child: ListTile(
                  leading: Icon(Icons.shield_outlined),
                  title: Text('Controles parentales'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'subscription',
                child: ListTile(
                  leading: Icon(Icons.card_membership),
                  title: Text('Suscripción'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesión'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(parentDashboardControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Resumen semanal
              _WeeklySummaryCard(stats: stats),
              const SizedBox(height: 16),

              // Gráfico de uso semanal
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uso de esta semana',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(
                      height: 180,
                      child: WeeklyUsageChart(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats detalladas
              _DetailedStatsCard(stats: stats),
              const SizedBox(height: 16),

              // Accesos rápidos
              _QuickAccessCard(
                title: 'Controles parentales',
                subtitle: 'Límite de tiempo, bedtime, categorías',
                icon: Icons.shield_outlined,
                onTap: () => context.push(Routes.parentalControls),
              ),
              const SizedBox(height: 8),
              _QuickAccessCard(
                title: 'Gestionar suscripción',
                subtitle: 'Plan, facturación, cancelar',
                icon: Icons.card_membership,
                onTap: () => context.push(Routes.subscription),
              ),
              const SizedBox(height: 8),
              _QuickAccessCard(
                title: 'Cerrar sesión',
                subtitle: 'Salir del panel de padres',
                icon: Icons.logout,
                onTap: () => _confirmLogout(context, ref),
                isDestructive: true,
              ),

              const SizedBox(height: 32),

              // Nota COPPA
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cumplimos con COPPA y GDPR-K. Tus datos y los de tu hijo están protegidos.',
                        style: Theme.of(context).textTheme.bodySmall,
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
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Salir del panel?'),
        content: const Text(
          'Vas a volver a la pantalla de inicio. '
          'Para volver a acceder al panel, necesitás el PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(parentDashboardControllerProvider.notifier).lockPanel();
              Navigator.of(context).pop();
              context.go(Routes.home);
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

/// Card con el resumen semanal: cuentos leídos + minutos + racha.
class _WeeklySummaryCard extends StatelessWidget {
  const _WeeklySummaryCard({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(
            context,
            value: '${stats.storiesCompleted}',
            label: 'Cuentos',
            icon: Icons.menu_book,
          ),
          _stat(
            context,
            value: '${stats.totalMinutes}m',
            label: 'Minutos',
            icon: Icons.access_time,
          ),
          _stat(
            context,
            value: '${stats.currentStreak}',
            label: 'Racha',
            icon: Icons.local_fire_department,
          ),
        ],
      ),
    );
  }

  Widget _stat(
    BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onPrimary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _DetailedStatsCard extends StatelessWidget {
  const _DetailedStatsCard({required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas detalladas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _statRow(context, 'Cuentos iniciados', '${stats.storiesStarted}'),
          _statRow(
              context, 'Cuentos completados', '${stats.storiesCompleted}'),
          _statRow(context, 'Tiempo total', '${stats.totalMinutes} minutos'),
          _statRow(context, 'Palabras aprendidas', '${stats.wordsLearned}'),
          _statRow(context, 'Racha más larga', '${stats.longestStreak} días'),
          _statRow(
              context, 'Categorías exploradas', '${stats.categoriesExplored}'),
          _statRow(context, 'Logros desbloqueados',
              '${stats.achievementsUnlocked}'),
        ],
      ),
    );
  }

  Widget _statRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
}

class _QuickAccessCard extends StatelessWidget {
  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDestructive
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
