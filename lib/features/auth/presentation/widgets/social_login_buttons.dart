import 'package:flutter/material.dart';

/// Botones de login social (Google + Apple).
///
/// Se muestran juntos en las pantallas de login y signup.
/// En iOS, el botón de Apple debe aparecer primero (política de Apple).
class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({
    super.key,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  final VoidCallback? onGoogleTap;
  final VoidCallback? onAppleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GoogleButton(
          onTap: onGoogleTap,
        ),
        const SizedBox(height: 12),
        _AppleButton(
          onTap: onAppleTap,
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      icon: const _GoogleLogo(size: 20),
      label: const Text(
        'Continuar con Google',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AppleButton extends StatelessWidget {
  const _AppleButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.apple, size: 22, color: Colors.white),
      label: const Text(
        'Continuar con Apple',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Logo de Google dibujado con CustomPainter (sin dependencia de asset).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Los 4 colores del logo de Google
    final blue = Paint()..color = const Color(0xFF4285F4);
    final red = Paint()..color = const Color(0xFFEA4335);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    // Arco derecho (azul)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi,
      false,
      blue,
    );

    // Arco izquierdo arriba (rojo)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 2,
      pi / 2,
      false,
      red,
    );

    // Arco izquierdo abajo (amarillo)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      pi / 2,
      false,
      yellow,
    );

    // Arco verde abajo
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi / 2,
      false,
      green,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const pi = 3.1415926535897932;
