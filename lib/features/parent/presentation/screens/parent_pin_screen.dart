import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/parent_dashboard_controller.dart';

/// Pantalla de ingreso de PIN para acceder al panel de padres.
///
/// El PIN es de 4 dígitos numéricos. Por defecto es "1234".
/// Después de 3 intentos fallidos, se bloquea por 30 segundos.
class ParentPinScreen extends ConsumerStatefulWidget {
  const ParentPinScreen({super.key});

  @override
  ConsumerState<ParentPinScreen> createState() => _ParentPinScreenState();
}

class _ParentPinScreenState extends ConsumerState<ParentPinScreen> {
  String _enteredPin = '';
  int _failedAttempts = 0;
  bool _isLocked = false;
  DateTime? _lockUntil;

  void _onDigitPressed(String digit) {
    if (_isLocked) return;
    if (_enteredPin.length >= 4) return;

    setState(() {
      _enteredPin += digit;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_isLocked) return;
    if (_enteredPin.isEmpty) return;
    setState(() {
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    final controller =
        ref.read(parentDashboardControllerProvider.notifier);
    final success = controller.verifyPin(_enteredPin);

    if (success) {
      // El controller ya seteó isPinVerified = true.
      // La pantalla dashboard observará el state y mostrará el contenido.
      setState(() {
        _enteredPin = '';
        _failedAttempts = 0;
      });
    } else {
      setState(() {
        _failedAttempts++;
        _enteredPin = '';
      });

      if (_failedAttempts >= 3) {
        setState(() {
          _isLocked = true;
          _lockUntil = DateTime.now().add(const Duration(seconds: 30));
        });
        _startLockTimer();
      }

      // Vibración de error
      HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _failedAttempts >= 3
                ? 'Demasiados intentos. Esperá 30 segundos.'
                : 'PIN incorrecto. Intentá de nuevo.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _startLockTimer() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isLocked = false;
          _failedAttempts = 0;
          _lockUntil = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acceso de padres'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Ingresá el PIN de padres',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLocked
                    ? 'Bloqueado. Esperá 30 segundos.'
                    : 'PIN por defecto: 1234 (cambialo en Configuración)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),

              // Indicador de 4 dígitos
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Teclado numérico
              _buildNumericKeypad(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKeypad() {
    return Column(
      children: [
        for (final row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          [null, '0', 'back']
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == null) {
                  return const SizedBox(width: 72, height: 72);
                }
                if (key == 'back') {
                  return _KeypadButton(
                    icon: Icons.backspace,
                    onTap: _onBackspace,
                    enabled: !_isLocked,
                  );
                }
                return _KeypadButton(
                  digit: key,
                  onTap: () => _onDigitPressed(key),
                  enabled: !_isLocked,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    this.digit,
    this.icon,
    required this.onTap,
    required this.enabled,
  });

  final String? digit;
  final IconData? icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: Center(
          child: digit != null
              ? Text(
                  digit!,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                )
              : Icon(icon, size: 28),
        ),
      ),
    );
  }
}
