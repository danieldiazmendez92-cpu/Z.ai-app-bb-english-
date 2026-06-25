import 'package:flutter/material.dart';

import '../../../../core/widgets/illustrations/story_illustration.dart';

/// Un hotspot en una ilustración: zona tappeable que reproduce
/// una palabra cuando el niño la toca.
///
/// Posición en coordenadas relativas (0.0 a 1.0) para que funcione
/// en cualquier tamaño de pantalla.
class IllustrationHotspot {
  const IllustrationHotspot({
    required this.id,
    required this.word,
    required this.translation,
    required this.x,
    required this.y,
    required this.radius,
    this.emoji,
  });

  /// ID único dentro del cuento.
  final String id;

  /// Palabra en inglés que se pronuncia al tap.
  final String word;

  /// Traducción al español (se muestra como tooltip).
  final String translation;

  /// Posición X relativa (0.0 = izquierda, 1.0 = derecha).
  final double x;

  /// Posición Y relativa (0.0 = arriba, 1.0 = abajo).
  final double y;

  /// Radio del hotspot en píxeles (zona tappeable).
  final double radius;

  /// Emoji opcional que se muestra sobre el hotspot.
  final String? emoji;
}

/// Catálogo de hotspots por storyId + sectionOrder.
///
/// Cada hotspot está posicionado sobre un elemento de la ilustración
/// (ej: el lobo, la casa, la estrella) para que al tocarlo el niño
/// escuche la palabra correspondiente.
class HotspotCatalog {
  HotspotCatalog._();

  /// Devuelve los hotspots para una sección de un cuento.
  /// Lista vacía si no hay hotspots definidos.
  static List<IllustrationHotspot> getHotspots({
    required String storyId,
    required int sectionOrder,
  }) {
    switch (storyId) {
      case 'little-red-riding-hood':
        return _littleRedRidingHood(sectionOrder);
      case 'three-little-pigs':
        return _threeLittlePigs(sectionOrder);
      case 'goldilocks':
        return _goldilocks(sectionOrder);
      case 'twinkle-twinkle':
        return _twinkleTwinkle();
      case 'itsy-bitsy-spider':
        return _itsyBitsySpider();
      case 'anansi-spider':
        return _anansiSpider();
      default:
        return [];
    }
  }

  static List<IllustrationHotspot> _littleRedRidingHood(int section) {
    switch (section) {
      case 1:
        return [
          IllustrationHotspot(
            id: 'lrh-1-tree',
            word: 'tree',
            translation: 'árbol',
            x: 0.25, y: 0.5, radius: 40,
            emoji: '🌳',
          ),
          IllustrationHotspot(
            id: 'lrh-1-girl',
            word: 'girl',
            translation: 'niña',
            x: 0.5, y: 0.75, radius: 35,
            emoji: '👧',
          ),
          IllustrationHotspot(
            id: 'lrh-1-sun',
            word: 'sun',
            translation: 'sol',
            x: 0.8, y: 0.2, radius: 30,
            emoji: '☀️',
          ),
        ];
      case 2:
        return [
          IllustrationHotspot(
            id: 'lrh-2-wolf',
            word: 'wolf',
            translation: 'lobo',
            x: 0.5, y: 0.6, radius: 40,
            emoji: '🐺',
          ),
          IllustrationHotspot(
            id: 'lrh-2-forest',
            word: 'forest',
            translation: 'bosque',
            x: 0.2, y: 0.5, radius: 35,
            emoji: '🌲',
          ),
        ];
      default:
        return [];
    }
  }

  static List<IllustrationHotspot> _threeLittlePigs(int section) {
    return [
      IllustrationHotspot(
        id: 'tlp-pig',
        word: 'pig',
        translation: 'cerdito',
        x: 0.5, y: 0.75, radius: 35,
        emoji: '🐷',
      ),
      IllustrationHotspot(
        id: 'tlp-house',
        word: 'house',
        translation: 'casa',
        x: 0.2, y: 0.5, radius: 40,
        emoji: '🏠',
      ),
      IllustrationHotspot(
        id: 'tlp-wolf',
        word: 'wolf',
        translation: 'lobo',
        x: 0.8, y: 0.7, radius: 35,
        emoji: '🐺',
      ),
    ];
  }

  static List<IllustrationHotspot> _goldilocks(int section) {
    return [
      IllustrationHotspot(
        id: 'g-bear',
        word: 'bear',
        translation: 'oso',
        x: 0.3, y: 0.6, radius: 35,
        emoji: '🐻',
      ),
      IllustrationHotspot(
        id: 'g-bowl',
        word: 'bowl',
        translation: 'cuenco',
        x: 0.6, y: 0.7, radius: 30,
        emoji: '🥣',
      ),
      IllustrationHotspot(
        id: 'g-bed',
        word: 'bed',
        translation: 'cama',
        x: 0.8, y: 0.5, radius: 35,
        emoji: '🛏️',
      ),
    ];
  }

  static List<IllustrationHotspot> _twinkleTwinkle() {
    return [
      IllustrationHotspot(
        id: 'tt-star',
        word: 'star',
        translation: 'estrella',
        x: 0.5, y: 0.4, radius: 40,
        emoji: '⭐',
      ),
      IllustrationHotspot(
        id: 'tt-moon',
        word: 'moon',
        translation: 'luna',
        x: 0.85, y: 0.15, radius: 30,
        emoji: '🌙',
      ),
      IllustrationHotspot(
        id: 'tt-sky',
        word: 'sky',
        translation: 'cielo',
        x: 0.2, y: 0.3, radius: 35,
        emoji: '🌌',
      ),
    ];
  }

  static List<IllustrationHotspot> _itsyBitsySpider() {
    return [
      IllustrationHotspot(
        id: 'ibs-spider',
        word: 'spider',
        translation: 'araña',
        x: 0.6, y: 0.7, radius: 35,
        emoji: '🕷️',
      ),
      IllustrationHotspot(
        id: 'ibs-rain',
        word: 'rain',
        translation: 'lluvia',
        x: 0.3, y: 0.3, radius: 35,
        emoji: '🌧️',
      ),
      IllustrationHotspot(
        id: 'ibs-sun',
        word: 'sun',
        translation: 'sol',
        x: 0.85, y: 0.15, radius: 30,
        emoji: '☀️',
      ),
    ];
  }

  static List<IllustrationHotspot> _anansiSpider() {
    return [
      IllustrationHotspot(
        id: 'as-spider',
        word: 'spider',
        translation: 'araña',
        x: 0.5, y: 0.6, radius: 35,
        emoji: '🕷️',
      ),
      IllustrationHotspot(
        id: 'as-tree',
        word: 'tree',
        translation: 'árbol',
        x: 0.5, y: 0.25, radius: 40,
        emoji: '🌳',
      ),
      IllustrationHotspot(
        id: 'as-pot',
        word: 'pot',
        translation: 'olla',
        x: 0.2, y: 0.8, radius: 30,
        emoji: '🍯',
      ),
    ];
  }
}

/// Widget que renderiza una ilustración con hotspots interactivos.
///
/// Combina [StoryIllustration] (CustomPainter) con botones circulares
/// invisibles/visibles que al tocarlos reproducen la palabra.
class InteractiveIllustration extends StatefulWidget {
  const InteractiveIllustration({
    super.key,
    required this.storyId,
    required this.sectionOrder,
    required this.onWordTap,
    this.size = 200,
    this.showHints = false,
  });

  final String storyId;
  final int sectionOrder;
  final void Function(String word, String translation) onWordTap;
  final double size;
  final bool showHints;

  @override
  State<InteractiveIllustration> createState() =>
      _InteractiveIllustrationState();
}

class _InteractiveIllustrationState extends State<InteractiveIllustration> {
  late List<IllustrationHotspot> _hotspots;
  String? _activeHotspotId;

  @override
  void initState() {
    super.initState();
    _hotspots = HotspotCatalog.getHotspots(
      storyId: widget.storyId,
      sectionOrder: widget.sectionOrder,
    );
  }

  @override
  void didUpdateWidget(InteractiveIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storyId != widget.storyId ||
        oldWidget.sectionOrder != widget.sectionOrder) {
      _hotspots = HotspotCatalog.getHotspots(
        storyId: widget.storyId,
        sectionOrder: widget.sectionOrder,
      );
      _activeHotspotId = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hotspots.isEmpty) {
      // Sin hotspots: solo la ilustración
      return StoryIllustration(
        storyId: widget.storyId,
        size: widget.size,
        borderRadius: 16,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        children: [
          // Ilustración de fondo
          Positioned.fill(
            child: StoryIllustration(
              storyId: widget.storyId,
              size: widget.size,
              borderRadius: 16,
            ),
          ),

          // Hotspots
          ..._hotspots.map((hotspot) {
            final isActive = _activeHotspotId == hotspot.id;
            return Positioned(
              left: hotspot.x * widget.size - hotspot.radius,
              top: hotspot.y * widget.size - hotspot.radius,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _activeHotspotId = hotspot.id;
                  });
                  widget.onWordTap(hotspot.word, hotspot.translation);
                  // Quitar el estado activo después de 1s
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() {
                        if (_activeHotspotId == hotspot.id) {
                          _activeHotspotId = null;
                        }
                      });
                    }
                  });
                },
                child: Container(
                  width: hotspot.radius * 2,
                  height: hotspot.radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4)
                        : (widget.showHints
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.15)
                            : Colors.transparent),
                    border: isActive || widget.showHints
                        ? Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          )
                        : null,
                  ),
                  child: (isActive || widget.showHints) && hotspot.emoji != null
                      ? Center(
                          child: Text(
                            hotspot.emoji!,
                            style: TextStyle(
                              fontSize: hotspot.radius * 0.8,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
