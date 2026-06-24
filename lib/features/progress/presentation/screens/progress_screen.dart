import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/progress_controller.dart';
import '../widgets/achievement_badge.dart';
import '../widgets/achievement_unlock_animation.dart';
import '../widgets/stats_card.dart';

/// Pantalla de progreso del niño.
///
/// Muestra:
/// - Stats principales (cuentos, minutos, racha, palabras)
/// - Nivel actual + barra de progreso al siguiente nivel
/// - Racha más larga + categorías exploradas
/// - Grid de insignias (desbloqueadas y bloqueadas)
///
/// Si se desbloquea un logro mientras está abierta, muestra animación.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(progressControllerProvider);
    final controller = ref.read(progressControllerProvider.notifier);

    // Mostrar animación si hay un logro recién desbloqueado
    if (state.newlyUnlocked != null) {
      return AchievementUnlockAnimation(
        achievement: state.newlyUnlocked!,
        onDismiss: controller.clearNewlyUnlocked,
      );
    }

    final stats = state.stats.valueOrNull;
    final achievements = state.allAchievements.valueOrNull ?? [];
    final unlocked = state.unlockedAchievements.valueOrNull ?? [];
    final unlockedIds = unlocked.map((ua) => ua.achievementId).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi progreso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: state.stats.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header con avatar + nivel
                    if (stats != null) _buildLevelHeader(context, stats),

                    const SizedBox(height: 24),

                    // Stats grid
                    if (stats != null) StatsGrid(stats: stats),

                    const SizedBox(height: 24),

                    // Stats secundarias
                    if (stats != null) _buildSecondaryStats(context, stats),

                    const SizedBox(height: 32),

                    // Logros
                    Text(
                      'Mis insignias',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${unlockedIds.length} de ${achievements.length} desbloqueadas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Grid de badges
                    if (achievements.isEmpty && state.allAchievements.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: controller.sortedAchievements.length,
                        itemBuilder: (context, index) {
                          final achievement =
                              controller.sortedAchievements[index];
                          final isUnlocked =
                              unlockedIds.contains(achievement.achievementId);
                          return AchievementBadge(
                            achievement: achievement,
                            isUnlocked: isUnlocked,
                            size: 110,
                            onTap: () {
                              // TODO: navegar a AchievementDetailScreen
                              _showAchievementDetail(
                                  context, achievement, isUnlocked);
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildLevelHeader(BuildContext context, dynamic stats) {
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
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${stats.level}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nivel ${stats.level}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stats.levelProgress / 100,
                    minHeight: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${stats.storiesCompleted} cuentos completados',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStats(BuildContext context, dynamic stats) {
    return Row(
      children: [
        Expanded(
          child: _miniStat(
            context,
            icon: Icons.emoji_events,
            value: '${stats.longestStreak}',
            label: 'Racha más larga',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniStat(
            context,
            icon: Icons.explore,
            value: '${stats.categoriesExplored}',
            label: 'Categorías',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _miniStat(
            context,
            icon: Icons.military_tech,
            value: '${stats.achievementsUnlocked}',
            label: 'Logros',
          ),
        ),
      ],
    );
  }

  Widget _miniStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _showAchievementDetail(
    BuildContext context,
    dynamic achievement,
    bool isUnlocked,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        achievement.emoji ?? achievement.iconUrl,
                        style: const TextStyle(fontSize: 48),
                      )
                    : Icon(
                        Icons.lock_outline,
                        size: 40,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isUnlocked
                  ? achievement.description
                  : (achievement.isHidden
                      ? '¡Seguí leyendo para desbloquear este logro sorpresa!'
                      : achievement.description),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${achievement.xpReward} XP',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
