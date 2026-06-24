import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/privacy_controller.dart';

/// Banner de consentimiento granular que se muestra al primer uso.
///
/// Cumple con GDPR-K Art. 7 (consentimiento) y COPPA (consentimiento parental).
///
/// Tres opciones:
/// - Necesario (siempre true, no se puede desactivar)
/// - Analytics (opt-in, default off)
/// - Personalización (opt-in, default off)
class ConsentBanner extends ConsumerStatefulWidget {
  const ConsentBanner({
    super.key,
    required this.onAccept,
  });

  final VoidCallback onAccept;

  @override
  ConsumerState<ConsentBanner> createState() => _ConsentBannerState();
}

class _ConsentBannerState extends ConsumerState<ConsentBanner> {
  bool _analytics = false;
  bool _personalization = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.privacy_tip,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tu privacidad es importante',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'StoryEnglish Kids cumple con COPPA y GDPR-K. '
              'Elegí qué datos querés compartir:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Necesario (siempre on)
            _ConsentRow(
              icon: Icons.check_circle,
              iconColor: Colors.green,
              title: 'Necesario',
              description: 'Funcionamiento básico de la app. No se puede desactivar.',
              value: true,
              onChanged: null,
            ),

            // Analytics
            _ConsentRow(
              icon: Icons.analytics_outlined,
              iconColor: Theme.of(context).colorScheme.primary,
              title: 'Analytics',
              description:
                  'Datos anónimos de uso para mejorar la app. Recomendado.',
              value: _analytics,
              onChanged: (v) => setState(() => _analytics = v!),
            ),

            // Personalización
            _ConsentRow(
              icon: Icons.tune,
              iconColor: Theme.of(context).colorScheme.primary,
              title: 'Personalización',
              description:
                  'Recomendaciones basadas en los gustos de tu hijo.',
              value: _personalization,
              onChanged: (v) => setState(() => _personalization = v!),
            ),

            const SizedBox(height: 16),
            Text(
              'Podés cambiar esto en cualquier momento desde '
              'Configuración → Privacidad.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                final controller =
                    ref.read(privacyControllerProvider.notifier);
                await controller.setAnalyticsConsent(_analytics);
                await controller.setPersonalizationConsent(_personalization);
                widget.onAccept();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Aceptar y continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
