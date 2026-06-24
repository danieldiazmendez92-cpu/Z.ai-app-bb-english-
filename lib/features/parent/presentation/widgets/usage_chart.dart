import 'dart:math';
import 'package:flutter/material.dart';

/// Bar chart semanal de uso (minutos por día).
///
/// Por ahora usa datos mockeados. En el futuro, se conecta a
/// `reading_sessions` agregadas por día.
///
/// Diseño simple sin dependencias externas (no usa charts_flutter ni
/// fl_chart para mantener el bundle liviano).
class WeeklyUsageChart extends StatefulWidget {
  const WeeklyUsageChart({super.key});

  @override
  State<WeeklyUsageChart> createState() => _WeeklyUsageChartState();
}

class _WeeklyUsageChartState extends State<WeeklyUsageChart> {
  // Datos mock por ahora: 7 días con minutos aleatorios
  // En el futuro: stream desde reading_sessions agregadas
  final List<_DayUsage> _data = List.generate(7, (index) {
    final now = DateTime.now();
    final date = now.subtract(Duration(days: 6 - index));
    final dayName = _dayName(date.weekday);
    // Mock: entre 0 y 30 minutos
    final minutes = index == 6 ? 18 : (index * 5 + (index % 3) * 4);
    return _DayUsage(name: dayName, minutes: minutes);
  });

  @override
  Widget build(BuildContext context) {
    final maxMinutes = _data.fold<int>(
      0,
      (max, d) => d.minutes > max ? d.minutes : max,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = (constraints.maxWidth - 6 * 8) / 7;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _data.map((day) {
            final barHeight = maxMinutes > 0
                ? (day.minutes / maxMinutes) *
                    (constraints.maxHeight - 30) // 30px para labels
                : 0.0;

            return SizedBox(
              width: barWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Valor encima de la barra
                  if (day.minutes > 0)
                    Text(
                      '${day.minutes}m',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  const SizedBox(height: 4),
                  // Barra
                  Container(
                    width: barWidth * 0.7,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: day.minutes > 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .surfaceVariant,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Label del día
                  Text(
                    day.name,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  static String _dayName(int weekday) {
    const names = ['', 'L', 'M', 'X', 'J', 'V', 'S', 'D'];
    return names[weekday];
  }
}

class _DayUsage {
  const _DayUsage({required this.name, required this.minutes});
  final String name;
  final int minutes;
}
