import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/se_button.dart';
import '../controllers/privacy_controller.dart';

/// Pantalla de privacidad y datos personales.
///
/// Permite al usuario:
/// - Ver y editar consentimiento granular (analytics, personalización)
/// - Exportar todos sus datos (GDPR Art. 20)
/// - Eliminar cuenta (GDPR Art. 17 + COPPA cleanup)
class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final state = ref.watch(privacyControllerProvider);
    final controller = ref.read(privacyControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidad y datos'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Sección consentimiento
            _Section(
              title: 'Consentimiento',
              icon: Icons.privacy_tip_outlined,
              children: [
                SwitchListTile(
                  title: const Text('Analytics'),
                  subtitle: const Text(
                    'Datos anónimos de uso para mejorar la app',
                  ),
                  value: state.consent.analytics,
                  onChanged: controller.setAnalyticsConsent,
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Personalización'),
                  subtitle: const Text(
                    'Recomendaciones basadas en los gustos de tu hijo',
                  ),
                  value: state.consent.personalization,
                  onChanged: controller.setPersonalizationConsent,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Necesario'),
                  subtitle: const Text(
                    'Funcionamiento básico. No se puede desactivar.',
                  ),
                  trailing: const Switch(
                    value: true,
                    onChanged: null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sección exportar datos
            _Section(
              title: 'Tus datos',
              icon: Icons.download_outlined,
              children: [
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Exportar todos mis datos'),
                  subtitle: const Text(
                    'Descargá un archivo JSON con toda la información que '
                    'tenemos de tu cuenta y la de tus hijos (GDPR Art. 20).',
                  ),
                  trailing: state.isExporting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: state.isExporting
                      ? null
                      : () async {
                          await controller.exportData();
                          if (state.exportedJson != null && context.mounted) {
                            _showExportedDialog(
                                context, state.exportedJson!);
                          }
                        },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sección eliminar cuenta
            _Section(
              title: 'Zona de peligro',
              icon: Icons.warning_amber,
              iconColor: Theme.of(context).colorScheme.error,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    'Eliminar mi cuenta',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: const Text(
                    'Borra permanentemente tu cuenta, configuración parental '
                    'y datos de tus hijos. Los perfiles de niños se borran '
                    'físicamente tras 30 días (COPPA). Esta acción no se puede '
                    'deshacer.',
                  ),
                  onTap: () => _confirmDelete(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Info legal
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cumplimiento legal',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• COPPA (Children\'s Online Privacy Protection Act) - EE.UU.\n'
                    '• GDPR-K (General Data Protection Regulation) - UE\n'
                    '• Ley 25.326 - Argentina\n'
                    '• LGPD - Brasil',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => context.push(Routes.privacy),
                    child: Text(
                      'Ver política de privacidad completa →',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportedDialog(BuildContext context, String json) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Datos exportados'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              const Text(
                'Tus datos se exportaron en formato JSON. '
                'En una app real, se descargaría como archivo. '
                'Para esta demo, te lo mostramos acá:',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  json.length > 1000
                      ? '${json.substring(0, 1000)}...\n\n[truncado, ${json.length} chars total]'
                      : json,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text(
          'Esta acción NO se puede deshacer.\n\n'
          'Se borrará:\n'
          '• Tu cuenta y configuración\n'
          '• Todos los perfiles de tus hijos\n'
          '• Todo el progreso y logros\n'
          '• Suscripción (si tenés)\n\n'
          'Los datos de tus hijos se borran físicamente tras 30 días '
          '(período de gracia por si te arrepentís).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _showFinalConfirmation(context, ref);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFinalConfirmation(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Última confirmación'),
        content: const Text(
          '¿Estás absolutamente seguro? Escribí "ELIMINAR" para confirmar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, eliminar todo'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(privacyControllerProvider.notifier).deleteAccount();

    if (!context.mounted) return;
    final state = ref.read(privacyControllerProvider);
    if (state.accountDeleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta eliminada. Te extrañaremos.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(Routes.login);
    } else if (state.failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.failure!.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
    this.iconColor,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
