import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/presentation/controllers/library_controller.dart';
import '../controllers/parent_dashboard_controller.dart';

/// Pantalla de controles parentales.
///
/// Permite al padre configurar:
/// - Límite diario de minutos (slider 0-120, 0 = sin límite)
/// - Bloqueo nocturno (bedtime start/end)
/// - Categorías bloqueadas (chips)
/// - Analytics opt-in (toggle, COPPA)
/// - Descargas offline (toggle)
class ParentalControlsScreen extends ConsumerWidget {
  const ParentalControlsScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(parentDashboardControllerProvider);
    final controller = ref.read(parentDashboardControllerProvider.notifier);
    final settingsAsync = state.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controles parentales'),
      ),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (settings) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Límite diario
                _buildSection(
                  context,
                  title: 'Límite diario',
                  icon: Icons.timer_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.dailyLimitMinutes == 0
                            ? 'Sin límite de tiempo'
                            : '${settings.dailyLimitMinutes} minutos por día',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: settings.dailyLimitMinutes.toDouble(),
                        min: 0,
                        max: 120,
                        divisions: 12,
                        label: settings.dailyLimitMinutes == 0
                            ? 'Sin límite'
                            : '${settings.dailyLimitMinutes} min',
                        onChanged: (value) {
                          controller.setDailyLimitMinutes(value.round());
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cuando el niño reacha el límite, la app le avisa y deja de contar tiempo de lectura.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),

                // Bedtime
                _buildSection(
                  context,
                  title: 'Bloqueo nocturno',
                  icon: Icons.bedtime_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bloquea el uso de la app en horario nocturno.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _TimePicker(
                              label: 'Desde',
                              value: settings.bedtimeStart,
                              onChanged: (time) => controller.setBedtime(
                                start: time,
                                end: settings.bedtimeEnd,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.arrow_forward),
                          ),
                          Expanded(
                            child: _TimePicker(
                              label: 'Hasta',
                              value: settings.bedtimeEnd,
                              onChanged: (time) => controller.setBedtime(
                                start: settings.bedtimeStart,
                                end: time,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (settings.hasBedtime) ...[
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => controller.setBedtime(
                            start: null,
                            end: null,
                          ),
                          child: const Text('Desactivar bedtime'),
                        ),
                      ],
                    ],
                  ),
                ),

                // Categorías bloqueadas
                _buildSection(
                  context,
                  title: 'Categorías bloqueadas',
                  icon: Icons.block,
                  child: _buildBlockedCategories(
                      context, settings.blockedCategories, controller),
                ),

                // Privacidad
                _buildSection(
                  context,
                  title: 'Privacidad',
                  icon: Icons.privacy_tip_outlined,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Permitir analytics'),
                        subtitle: const Text(
                          'Recopilamos datos anónimos de uso para mejorar la app. '
                          'Nunca compartimos información personal de tu hijo.',
                        ),
                        value: settings.allowAnalytics,
                        onChanged: controller.setAllowAnalytics,
                      ),
                      const Divider(),
                      SwitchListTile(
                        title: const Text('Permitir descargas offline'),
                        subtitle: const Text(
                          'Permite descargar cuentos para usar sin conexión.',
                        ),
                        value: settings.allowOfflineDownload,
                        onChanged: controller.setAllowOfflineDownload,
                      ),
                    ],
                  ),
                ),

                // Nota COPPA
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.gavel,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Las publicidades personalizadas están deshabilitadas '
                          'permanentemente para cumplir con COPPA.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBlockedCategories(
    BuildContext context,
    List<String> blocked,
    ParentDashboardController controller,
  ) {
    final categories = ref.read(categoriesProvider);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isBlocked = blocked.contains(cat.categoryId);
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(cat.iconAsset, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(cat.nameEs),
            ],
          ),
          selected: isBlocked,
          onSelected: (_) => controller.toggleBlockedCategory(cat.categoryId),
          selectedColor: Theme.of(context).colorScheme.error,
          labelStyle: TextStyle(
            color: isBlocked
                ? Theme.of(context).colorScheme.onError
                : null,
          ),
        );
      }).toList(),
    );
  }
}

/// Picker de hora simple que usa TimePickerDialog de Material.
class _TimePicker extends StatelessWidget {
  const _TimePicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        TimeOfDay? initial;
        if (value != null) {
          final parts = value!.split(':');
          initial = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
        final picked = await showTimePicker(
          context: context,
          initialTime: initial ?? TimeOfDay.now(),
          helpText: 'Seleccioná la hora',
        );
        if (picked != null) {
          final hh = picked.hour.toString().padLeft(2, '0');
          final mm = picked.minute.toString().padLeft(2, '0');
          onChanged('$hh:$mm');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value ?? '--:--',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
