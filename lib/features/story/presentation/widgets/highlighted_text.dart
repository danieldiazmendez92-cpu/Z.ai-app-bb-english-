import 'package:flutter/material.dart';

/// Widget que renderiza texto con una palabra resaltada.
///
/// Se usa en el Reader para mostrar el texto del cuento en inglés
/// y resaltar la palabra que se está reproduciendo del audio.
///
/// El resaltado se hace pasando [highlightIndex] (índice de la palabra
/// actual en la lista de palabras del texto).
class HighlightedText extends StatelessWidget {
  const HighlightedText({
    super.key,
    required this.text,
    this.highlightIndex,
    this.highlightedWordIndices = const {},
    this.onWordTap,
    this.style,
    this.highlightStyle,
    this.vocabStyle,
  });

  /// Texto completo a mostrar (en inglés).
  final String text;

  /// Índice de la palabra que se está reproduciendo (resaltado de audio).
  final int? highlightIndex;

  /// Índices de palabras que son vocabulario destacado (subrayado).
  final Set<int> highlightedWordIndices;

  /// Callback al tap sobre una palabra.
  /// Recibe la palabra y su índice.
  final void Function(String word, int index)? onWordTap;

  /// Estilo del texto normal.
  final TextStyle? style;

  /// Estilo de la palabra reproduciéndose (audio sync).
  final TextStyle? highlightStyle;

  /// Estilo de palabras de vocabulario destacado.
  final TextStyle? vocabStyle;

  @override
  Widget build(BuildContext context) {
    final words = _splitWords(text);
    final defaultStyle = style ??
        TextStyle(
          fontSize: 24,
          height: 1.8,
          color: Theme.of(context).colorScheme.onSurface,
        );
    final audioHighlight = highlightStyle ??
        TextStyle(
          fontSize: 24,
          height: 1.8,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        );
    final vocabHighlight = vocabStyle ??
        TextStyle(
          fontSize: 24,
          height: 1.8,
          color: Theme.of(context).colorScheme.tertiary,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
        );

    return RichText(
      text: _buildTextSpan(
        words: words,
        defaultStyle: defaultStyle,
        audioHighlight: audioHighlight,
        vocabHighlight: vocabHighlight,
        context: context,
      ),
    );
  }

  TextSpan _buildTextSpan({
    required List<String> words,
    required TextStyle defaultStyle,
    required TextStyle audioHighlight,
    required TextStyle vocabHighlight,
    required BuildContext context,
  }) {
    final children = <InlineSpan>[];

    for (var i = 0; i < words.length; i++) {
      final word = words[i];
      final isAudioHighlight = i == highlightIndex;
      final isVocab = highlightedWordIndices.contains(i);

      TextStyle style;
      if (isAudioHighlight) {
        style = audioHighlight;
      } else if (isVocab) {
        style = vocabHighlight;
      } else {
        style = defaultStyle;
      }

      if (onWordTap != null && isVocab) {
        // Widget tappeable para vocabulario
        children.add(
          WidgetSpan(
            child: GestureDetector(
              onTap: () => onWordTap!(word, i),
              child: Text(word, style: style),
            ),
          ),
        );
      } else {
        children.add(TextSpan(text: word, style: style));
      }

      // Espacio entre palabras (excepto después de la última)
      if (i < words.length - 1) {
        children.add(TextSpan(text: ' ', style: defaultStyle));
      }
    }

    return TextSpan(children: children);
  }

  /// Divide el texto en palabras preservando puntuación.
  List<String> _splitWords(String text) {
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }
}
