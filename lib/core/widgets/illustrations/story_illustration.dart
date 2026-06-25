import 'package:flutter/material.dart';

/// Widget que renderiza una ilustración temática para un cuento.
///
/// Reemplaza los emojis por escenas coloridas hechas con CustomPainter.
/// Cada storyId tiene su propio painter con colores y formas temáticas.
///
/// En producción, estas se reemplazarían por SVG/PNG de un designer.
/// Para MVP, generamos arte programático que es más rico visualmente
/// que un emoji simple.
class StoryIllustration extends StatelessWidget {
  const StoryIllustration({
    super.key,
    required this.storyId,
    this.size = 120,
    this.borderRadius = 16,
  });

  final String storyId;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _getPainterForStory(storyId),
          size: Size(size, size),
        ),
      ),
    );
  }

  CustomPainter _getPainterForStory(String storyId) {
    switch (storyId) {
      case 'little-red-riding-hood':
        return const _ForestScenePainter();
      case 'three-little-pigs':
        return const _ThreeHousesPainter();
      case 'goldilocks':
        return const _ThreeBearsPainter();
      case 'ugly-duckling':
        return const _PondScenePainter();
      case 'tortoise-hare':
        return const _RaceScenePainter();
      case 'twinkle-twinkle':
        return const _StarrySkyPainter();
      case 'humpty-dumpty':
        return const _WallScenePainter();
      case 'itsy-bitsy-spider':
        return const _RainScenePainter();
      case 'anansi-spider':
        return const _TreeScenePainter();
      case 'three-wishes':
        return const _MagicBirdPainter();
      default:
        return const _DefaultScenePainter();
    }
  }
}

// ============================================================
// Painters individuales por cuento
// ============================================================

/// Escena de bosque para Little Red Riding Hood.
class _ForestScenePainter extends CustomPainter {
  const _ForestScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Sol
    final sunPaint = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.2),
      size.width * 0.1,
      sunPaint,
    );

    // Árboles (3 pinos)
    final treePaint = Paint()..color = const Color(0xFF2E7D32);
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.3);
      final baseY = size.height * 0.9;
      // Tronco
      final trunkPaint = Paint()..color = const Color(0xFF6D4C41);
      canvas.drawRect(
        Rect.fromLTWH(x - size.width * 0.03, baseY - size.height * 0.15,
            size.width * 0.06, size.height * 0.15),
        trunkPaint,
      );
      // Copa (triángulo)
      final path = Path()
        ..moveTo(x, baseY - size.height * 0.6)
        ..lineTo(x - size.width * 0.12, baseY - size.height * 0.15)
        ..lineTo(x + size.width * 0.12, baseY - size.height * 0.15)
        ..close();
      canvas.drawPath(path, treePaint);
    }

    // Caperucita (figura roja pequeña)
    final girlPaint = Paint()..color = const Color(0xFFD32F2F);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.75),
      size.width * 0.06,
      girlPaint,
    );
    // Capa
    final capePath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.78)
      ..lineTo(size.width * 0.42, size.height * 0.92)
      ..lineTo(size.width * 0.58, size.height * 0.92)
      ..close();
    canvas.drawPath(capePath, girlPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tres casas para Three Little Pigs.
class _ThreeHousesPainter extends CustomPainter {
  const _ThreeHousesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Pasto
    final grassPaint = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.7, size.width, size.height * 0.3),
      grassPaint,
    );

    // Casa 1: paja (amarilla)
    _drawHouse(canvas, size, size.width * 0.2, const Color(0xFFFFEB3B));
    // Casa 2: madera (marrón)
    _drawHouse(canvas, size, size.width * 0.5, const Color(0xFF8D6E63));
    // Casa 3: ladrillos (rojo)
    _drawHouse(canvas, size, size.width * 0.8, const Color(0xFFD32F2F));
  }

  void _drawHouse(Canvas canvas, Size size, double cx, Color color) {
    final housePaint = Paint()..color = color;
    final roofPaint = Paint()..color = const Color(0xFF4E342E);
    final w = size.width * 0.2;
    final h = size.height * 0.35;
    final baseY = size.height * 0.7;

    // Pared
    canvas.drawRect(
      Rect.fromLTWH(cx - w / 2, baseY - h, w, h),
      housePaint,
    );
    // Techo (triángulo)
    final path = Path()
      ..moveTo(cx - w / 2 - 5, baseY - h)
      ..lineTo(cx, baseY - h - w * 0.4)
      ..lineTo(cx + w / 2 + 5, baseY - h)
      ..close();
    canvas.drawPath(path, roofPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tres osos para Goldilocks.
class _ThreeBearsPainter extends CustomPainter {
  const _ThreeBearsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Bosque
    final bgPaint = Paint()..color = const Color(0xFF81C784);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Tres osos (tamaños diferente)
    _drawBear(canvas, size, size.width * 0.25, size.height * 0.7, size.width * 0.12,
        const Color(0xFF6D4C41)); // Papa
    _drawBear(canvas, size, size.width * 0.5, size.height * 0.75, size.width * 0.10,
        const Color(0xFFA1887F)); // Mama
    _drawBear(canvas, size, size.width * 0.75, size.height * 0.8, size.width * 0.07,
        const Color(0xFFD7CCC8)); // Bebé
  }

  void _drawBear(
      Canvas canvas, Size size, double cx, double cy, double r, Color color) {
    final paint = Paint()..color = color;
    // Cuerpo
    canvas.drawCircle(Offset(cx, cy), r, paint);
    // Cabeza
    canvas.drawCircle(Offset(cx, cy - r * 1.2), r * 0.7, paint);
    // Orejas
    canvas.drawCircle(Offset(cx - r * 0.5, cy - r * 1.7), r * 0.25, paint);
    canvas.drawCircle(Offset(cx + r * 0.5, cy - r * 1.7), r * 0.25, paint);
    // Hocico
    final snoutPaint = Paint()..color = const Color(0xFFFFCCBC);
    canvas.drawCircle(Offset(cx, cy - r * 1.0), r * 0.25, snoutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Estanque con cisne para Ugly Duckling.
class _PondScenePainter extends CustomPainter {
  const _PondScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo
    final skyPaint = Paint()..color = const Color(0xFFB3E5FC);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Estanque
    final pondPaint = Paint()..color = const Color(0xFF0288D1);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.5,
        size.width * 0.8,
        size.height * 0.4,
      ),
      pondPaint,
    );

    // Cisne blanco
    final swanPaint = Paint()..color = Colors.white;
    final cx = size.width * 0.5;
    final cy = size.height * 0.65;
    // Cuerpo
    canvas.drawOval(
      Rect.fromLTWH(cx - size.width * 0.12, cy - size.height * 0.05,
          size.width * 0.24, size.height * 0.12),
      swanPaint,
    );
    // Cuello (curva)
    final neckPath = Path()
      ..moveTo(cx + size.width * 0.08, cy - size.height * 0.02)
      ..quadraticBezierTo(
        cx + size.width * 0.15,
        cy - size.height * 0.15,
        cx + size.width * 0.05,
        cy - size.height * 0.2,
      );
    canvas.drawPath(
      neckPath,
      swanPaint..style = PaintingStyle.stroke..strokeWidth = 8,
    );
    // Cabeza
    canvas.drawCircle(
      Offset(cx + size.width * 0.05, cy - size.height * 0.2),
      size.width * 0.03,
      swanPaint,
    );
    // Pico
    final beakPaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawOval(
      Rect.fromLTWH(
        cx + size.width * 0.07,
        cy - size.height * 0.21,
        size.width * 0.04,
        size.height * 0.02,
      ),
      beakPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Línea de carrera para Tortoise & Hare.
class _RaceScenePainter extends CustomPainter {
  const _RaceScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Pista
    final trackPaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.65, size.width, size.height * 0.35),
      trackPaint,
    );

    // Tortuga (adelante)
    _drawTortoise(canvas, size, size.width * 0.7, size.height * 0.75);
    // Liebre (dormida)
    _drawHare(canvas, size, size.width * 0.3, size.height * 0.75);

    // Meta (bandera a cuadros)
    final flagPaint = Paint()..color = Colors.black;
    for (var i = 0; i < 8; i++) {
      final color = i % 2 == 0 ? Colors.black : Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.92,
          size.height * (0.3 + i * 0.04),
          size.width * 0.06,
          size.height * 0.04,
        ),
        Paint()..color = color,
      );
    }
  }

  void _drawTortoise(Canvas canvas, Size size, double cx, double cy) {
    // Caparazón
    final shellPaint = Paint()..color = const Color(0xFF4CAF50);
    canvas.drawOval(
      Rect.fromLTWH(
          cx - size.width * 0.08, cy - size.height * 0.04,
          size.width * 0.16, size.height * 0.1),
      shellPaint,
    );
    // Cabeza
    canvas.drawCircle(
      Offset(cx + size.width * 0.1, cy),
      size.width * 0.03,
      shellPaint,
    );
    // Patas
    final legPaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(Offset(cx - size.width * 0.05, cy + size.height * 0.05),
        size.width * 0.02, legPaint);
    canvas.drawCircle(Offset(cx + size.width * 0.05, cy + size.height * 0.05),
        size.width * 0.02, legPaint);
  }

  void _drawHare(Canvas canvas, Size size, double cx, double cy) {
    // Cuerpo
    final paint = Paint()..color = const Color(0xFFE0E0E0);
    canvas.drawOval(
      Rect.fromLTWH(
          cx - size.width * 0.06, cy - size.height * 0.03,
          size.width * 0.12, size.height * 0.08),
      paint,
    );
    // Oreja larga
    canvas.drawOval(
      Rect.fromLTWH(
          cx - size.width * 0.02, cy - size.height * 0.12,
          size.width * 0.015, size.height * 0.08),
      paint,
    );
    canvas.drawOval(
      Rect.fromLTWH(
          cx + size.width * 0.005, cy - size.height * 0.12,
          size.width * 0.015, size.height * 0.08),
      paint,
    );
    // Zzz (dormida)
    final zPaint = Paint()
      ..color = const Color(0xFF9E9E9E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(
      Path()
        ..moveTo(cx + size.width * 0.08, cy - size.height * 0.1)
        ..lineTo(cx + size.width * 0.12, cy - size.height * 0.1)
        ..moveTo(cx + size.width * 0.1, cy - size.height * 0.12)
        ..lineTo(cx + size.width * 0.1, cy - size.height * 0.08),
      zPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cielo estrellado para Twinkle Twinkle.
class _StarrySkyPainter extends CustomPainter {
  const _StarrySkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo nocturno (gradiente simulado con rectángulos)
    final bgPaint = Paint()
      ..color = const Color(0xFF1A237E);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Estrellas pequeñas
    final starPaint = Paint()..color = Colors.white;
    final rand = [0.1, 0.25, 0.4, 0.6, 0.75, 0.9, 0.15, 0.55, 0.85];
    for (var i = 0; i < rand.length; i++) {
      final x = size.width * rand[i];
      final y = size.height * rand[(i + 3) % rand.length] * 0.6;
      canvas.drawCircle(Offset(x, y), 2, starPaint);
    }

    // Estrella grande central (con brillo)
    final cx = size.width * 0.5;
    final cy = size.height * 0.4;
    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFFEB3B).withOpacity(0.3);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.15, glowPaint);
    // Estrella
    final starPath = Path();
    final outer = size.width * 0.08;
    final inner = size.width * 0.03;
    for (var i = 0; i < 10; i++) {
      final angle = (i * pi / 5) - pi / 2;
      final r = i % 2 == 0 ? outer : inner;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = const Color(0xFFFFEB3B));

    // Luna
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.08,
      Paint()..color = const Color(0xFFFFF9C4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Muro para Humpty Dumpty.
class _WallScenePainter extends CustomPainter {
  const _WallScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo
    final skyPaint = Paint()..color = const Color(0xFF87CEEB);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Muro de ladrillos
    final brickPaint = Paint()..color = const Color(0xFFB71C1C);
    final mortarPaint = Paint()..color = const Color(0xFFE0E0E0);
    final wallY = size.height * 0.5;
    final wallH = size.height * 0.4;
    canvas.drawRect(
      Rect.fromLTWH(0, wallY, size.width, wallH),
      brickPaint,
    );
    // Líneas de mortero (horizontales)
    for (var i = 1; i < 4; i++) {
      final y = wallY + (wallH / 4) * i;
      canvas.drawRect(
        Rect.fromLTWH(0, y - 1, size.width, 2),
        mortarPaint,
      );
    }
    // Líneas verticales (offset por fila)
    for (var row = 0; row < 4; row++) {
      final y = wallY + (wallH / 4) * row;
      final offset = row % 2 == 0 ? 0.0 : size.width * 0.15;
      for (var i = 0; i < 4; i++) {
        final x = size.width * 0.3 * i + offset;
        canvas.drawRect(
          Rect.fromLTWH(x - 1, y, 2, wallH / 4),
          mortarPaint,
        );
      }
    }

    // Huevo (Humpty) sobre el muro
    final eggPaint = Paint()..color = Colors.white;
    final eggX = size.width * 0.5;
    final eggY = wallY - size.height * 0.1;
    canvas.drawOval(
      Rect.fromLTWH(
          eggX - size.width * 0.06, eggY - size.height * 0.15,
          size.width * 0.12, size.height * 0.25),
      eggPaint,
    );
    // Ojos
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(eggX - size.width * 0.02, eggY - size.height * 0.05),
      2, eyePaint);
    canvas.drawCircle(
      Offset(eggX + size.width * 0.02, eggY - size.height * 0.05),
      2, eyePaint);
    // Sonrisa
    canvas.drawPath(
      Path()
        ..moveTo(eggX - size.width * 0.02, eggY + size.height * 0.01)
        ..quadraticBezierTo(
          eggX, eggY + size.height * 0.04,
          eggX + size.width * 0.02, eggY + size.height * 0.01),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Lluvia para Itsy Bitsy Spider.
class _RainScenePainter extends CustomPainter {
  const _RainScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo gris
    final skyPaint = Paint()..color = const Color(0xFF78909C);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Lluvia (líneas diagonales)
    final rainPaint = Paint()
      ..color = const Color(0xFF42A5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 20; i++) {
      final x = (i * size.width / 10) % size.width;
      final y = (i * 37) % size.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x + 5, y + 15),
        rainPaint,
      );
    }

    // Desagüe (tubería vertical)
    final pipePaint = Paint()..color = const Color(0xFF424242);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.3, size.height * 0.3,
        size.width * 0.1, size.height * 0.6),
      pipePaint,
    );

    // Araña
    final spiderPaint = Paint()..color = Colors.black;
    final sx = size.width * 0.6;
    final sy = size.height * 0.7;
    canvas.drawCircle(Offset(sx, sy), size.width * 0.06, spiderPaint);
    // Patas
    final legPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    for (var i = 0; i < 4; i++) {
      final angle = (i - 1.5) * 0.5;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(
          sx + cos(angle) * size.width * 0.12,
          sy + sin(angle) * size.width * 0.12,
        ),
        legPaint,
      );
    }

    // Sol asomando
    final sunPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.08,
      sunPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Árbol para Anansi.
class _TreeScenePainter extends CustomPainter {
  const _TreeScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Sabana (cielo amarillo cálido)
    final skyPaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRect(Offset.zero & size, skyPaint);

    // Tierra
    final earthPaint = Paint()..color = const Color(0xFF8D6E63);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.8, size.width, size.height * 0.2),
      earthPaint,
    );

    // Tronco del árbol
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.4, size.height * 0.3,
        size.width * 0.2, size.height * 0.5),
      trunkPaint,
    );

    // Copa del árbol (grande, redonda)
    final leavesPaint = Paint()..color = const Color(0xFF388E3C);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.25),
      size.width * 0.25,
      leavesPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.3),
      size.width * 0.15,
      leavesPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.3),
      size.width * 0.15,
      leavesPaint,
    );

    // Araña Anansi (subiendo el tronco)
    final spiderPaint = Paint()..color = Colors.black;
    final sx = size.width * 0.5;
    final sy = size.height * 0.6;
    canvas.drawCircle(Offset(sx, sy), size.width * 0.04, spiderPaint);
    final legPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 4; i++) {
      final angle = (i - 1.5) * 0.4;
      canvas.drawLine(
        Offset(sx, sy),
        Offset(
          sx + cos(angle) * size.width * 0.08,
          sy + sin(angle) * size.width * 0.08,
        ),
        legPaint,
      );
    }

    // Olla en el suelo (dorada)
    final potPaint = Paint()..color = const Color(0xFFD4AF37);
    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.15, size.height * 0.75,
        size.width * 0.15, size.height * 0.1),
      potPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Pájaro mágico para Three Wishes.
class _MagicBirdPainter extends CustomPainter {
  const _MagicBirdPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Cielo atardecer
    final sunsetPaint = Paint()
      ..color = const Color(0xFFFF7043);
    canvas.drawRect(Offset.zero & size, sunsetPaint);

    // Sol
    final sunPaint = Paint()..color = const Color(0xFFFFEB3B);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.7),
      size.width * 0.15,
      sunPaint,
    );

    // Pájaro mágico (colorido, volando)
    final cx = size.width * 0.5;
    final cy = size.height * 0.35;

    // Cuerpo
    final bodyPaint = Paint()..color = const Color(0xFF7B1FA2);
    canvas.drawOval(
      Rect.fromLTWH(
          cx - size.width * 0.06, cy - size.height * 0.04,
          size.width * 0.12, size.height * 0.1),
      bodyPaint,
    );

    // Ala desplegada (izquierda)
    final wingPath = Path()
      ..moveTo(cx - size.width * 0.04, cy)
      ..quadraticBezierTo(
        cx - size.width * 0.2, cy - size.height * 0.1,
        cx - size.width * 0.2, cy + size.height * 0.05)
      ..quadraticBezierTo(
        cx - size.width * 0.15, cy + size.height * 0.02,
        cx - size.width * 0.04, cy + size.height * 0.02)
      ..close();
    canvas.drawPath(wingPath, Paint()..color = const Color(0xFFE91E63));

    // Ala derecha (espejo)
    final wingPath2 = Path()
      ..moveTo(cx + size.width * 0.04, cy)
      ..quadraticBezierTo(
        cx + size.width * 0.2, cy - size.height * 0.1,
        cx + size.width * 0.2, cy + size.height * 0.05)
      ..quadraticBezierTo(
        cx + size.width * 0.15, cy + size.height * 0.02,
        cx + size.width * 0.04, cy + size.height * 0.02)
      ..close();
    canvas.drawPath(wingPath2, Paint()..color = const Color(0xFFE91E63));

    // Cabeza
    canvas.drawCircle(
      Offset(cx + size.width * 0.08, cy - size.height * 0.04),
      size.width * 0.03,
      bodyPaint,
    );
    // Pico
    final beakPaint = Paint()..color = const Color(0xFFFF9800);
    canvas.drawPath(
      Path()
        ..moveTo(cx + size.width * 0.1, cy - size.height * 0.04)
        ..lineTo(cx + size.width * 0.14, cy - size.height * 0.03)
        ..lineTo(cx + size.width * 0.1, cy - size.height * 0.02)
        ..close(),
      beakPaint,
    );

    // Estrellas mágicas alrededor
    final magicPaint = Paint()..color = const Color(0xFFFFEB3B);
    for (final (x, y) in [
      (0.2, 0.2), (0.8, 0.15), (0.3, 0.5), (0.75, 0.55), (0.15, 0.4)
    ]) {
      canvas.drawCircle(
        Offset(size.width * x, size.height * y),
        3,
        magicPaint,
      );
    }
  }

  @override
  bool shouldRepant(covariant CustomPainter oldDelegate) => false;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Escena por defecto (libro).
class _DefaultScenePainter extends CustomPainter {
  const _DefaultScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A90E2);
    canvas.drawRect(Offset.zero & size, paint);
    // Libro
    final bookPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.2, size.height * 0.25,
          size.width * 0.6, size.height * 0.5),
      bookPaint,
    );
    // Línea central del libro
    final linePaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.5, size.height * 0.75),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Constantes matemáticas (sin import dart:math para mantener limpio)
const pi = 3.1415926535897932;

double cos(double x) {
  // Taylor series simplificado (suficiente para nuestros ángulos)
  while (x > pi) x -= 2 * pi;
  while (x < -pi) x += 2 * pi;
  return 1 - x * x / 2 + x * x * x * x / 24 - x * x * x * x * x * x / 720;
}

double sin(double x) {
  return cos(x - pi / 2);
}
