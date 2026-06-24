import 'package:flutter/material.dart';

import '../../domain/entities/reading_stats.dart';

/// Card que muestra una estadística individual con icono + valor + label.
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

/// Grid de stats que muestra las 4 principales: cuentos, minutos, racha, palabras.
class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.stats});

  final ReadingStats stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        StatsCard(
          icon: Icons.menu_book,
          iconColor: Colors.blue,
          value: '${stats.storiesCompleted}',
          label: 'Cuentos leídos',
        ),
        StatsCard(
          icon: Icons.access_time,
          iconColor: Colors.green,
          value: '${stats.totalMinutes}',
          label: 'Minutos leídos',
        ),
        StatsCard(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          value: '${stats.currentStreak}',
          label: 'Días seguidos',
        ),
        StatsCard(
          icon: Icons.spellcheck,
          iconColor: Colors.purple,
          value: '${stats.wordsLearned}',
          label: 'Palabras aprendidas',
        ),
      ],
    );
  }
}
