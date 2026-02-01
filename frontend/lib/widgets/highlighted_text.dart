import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle normalStyle;
  final TextAlign textAlign;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    required this.normalStyle,
    this.textAlign = TextAlign.start,
  });

  // 根据主题获取高亮样式
  TextStyle _getHighlightStyle(BuildContext context) {
    return normalStyle.copyWith(
      color: const Color(0xFF238636),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: normalStyle, textAlign: textAlign);
    }

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final matches = <TextSpan>[];
    int currentIndex = 0;

    final effectiveHighlightStyle = _getHighlightStyle(context);

    while (currentIndex < text.length) {
      final matchIndex = lowerText.indexOf(lowerHighlight, currentIndex);

      if (matchIndex == -1) {
        // No more matches
        matches.add(
          TextSpan(text: text.substring(currentIndex), style: normalStyle),
        );
        break;
      }

      // Add text before the match
      if (matchIndex > currentIndex) {
        matches.add(
          TextSpan(
            text: text.substring(currentIndex, matchIndex),
            style: normalStyle,
          ),
        );
      }

      // Add the matched text
      matches.add(
        TextSpan(
          text: text.substring(matchIndex, matchIndex + highlight.length),
          style: effectiveHighlightStyle,
        ),
      );

      currentIndex = matchIndex + highlight.length;
    }

    return RichText(
      text: TextSpan(children: matches, style: normalStyle),
      textAlign: textAlign,
    );
  }
}
