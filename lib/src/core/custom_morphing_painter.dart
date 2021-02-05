import 'package:flutter/material.dart';

class CustomMorphingText extends StatelessWidget {
  const CustomMorphingText({Key key, @required this.morphingText})
      : assert(
          morphingText is CustomMorphingPainter,
          "Provider a CustomMorphingText",
        ),
        super(key: key);

  final CustomMorphingPainter morphingText;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: morphingText,
      ),
    );
  }
}

abstract class CustomMorphingPainter extends CustomPainter {
  CustomMorphingPainter(
    this.text,
    this.textStyle,
    this.progress,
  )   : assert(text != null),
        assert(textStyle != null),
        assert(progress != null);

  final String text;
  final TextStyle textStyle;
  final double progress;

  List<TextProperties> _textProperties = [];
  List<TextProperties> _oldTextProperties = [];

  String _oldText;

  @override
  @mustCallSuper
  void paint(Canvas canvas, Size size) {
    // calculate text info for 1st time
    if (_textProperties.length == 0) {
      _calculateTextProperties(text, _textProperties);
    }

    canvas.save();

    if (_oldTextProperties != null && _oldTextProperties.length > 0) {
      for (TextProperties _oldTextProperty in _oldTextProperties) {
        if (_oldTextProperty._isMoving)
          _drawText(canvas, morphingText(_oldTextProperty));
        else
          _drawText(canvas, outgoingText(_oldTextProperty));
      }
    }

    for (TextProperties _textProperty in _textProperties) {
      if (!_textProperty._isMoving)
        _drawText(canvas, incomingText(_textProperty));
    }

    canvas.restore();
  }

  @override
  @mustCallSuper
  bool shouldRepaint(CustomMorphingPainter oldDelegate) {
    String oldFrameText = oldDelegate.text;
    if (oldFrameText == text) {
      this._oldText = oldDelegate._oldText;
      this._oldTextProperties = oldDelegate._oldTextProperties;
      this._textProperties = oldDelegate._textProperties;
      // shouldn't repaint if there is not change in progress
      if (this.progress == oldDelegate.progress) {
        return false;
      }
    } else {
      this._oldText = oldDelegate.text;
      // calculate text info for prev and current text
      _calculateTextProperties(text, _textProperties);
      _calculateTextProperties(_oldText, _oldTextProperties);
      // calculate which text will move to which position
      _calculateMove();
    }
    return true;
  }

  void _drawText(Canvas canvas, TextProperties textProperties) {
    final textPaint = Paint();
    if (textProperties.opacity == 1) {
      textPaint.color = textStyle.color;
    } else {
      textPaint.color = textStyle.color.withAlpha(
        (textStyle.color.alpha * textProperties.opacity).floor(),
      );
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: textProperties.text,
        style: textStyle.merge(
          TextStyle(
            color: textPaint.color,
          ),
        ),
      ),
    )
      ..textDirection = TextDirection.ltr
      ..textAlign = TextAlign.center
      ..textDirection = TextDirection.ltr
      ..layout();

    textPainter.paint(
      canvas,
      Offset(
        textProperties.offsetX,
        textProperties.offsetY,
      ),
    );
  }

  void _calculateTextProperties(String text, List<TextProperties> list) {
    list.clear();

    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textAlign: TextAlign.center,
    )..layout();

    // spliting the text and storing thier infomation for each
    for (int i = 0; i < text.length; i++) {
      var forCaret =
          textPainter.getOffsetForCaret(TextPosition(offset: i), Rect.zero);

      var textLayoutInfo = TextProperties()
        ..text = text[i]
        ..offsetX = forCaret.dx - textPainter.width / 2
        ..offsetY = forCaret.dy
        ..width = 0
        ..height = textPainter.height;

      list.add(textLayoutInfo);
    }
  }

  void _calculateMove() {
    if (_oldTextProperties == null || _oldTextProperties.length == 0) {
      return;
    }
    if (_textProperties == null || _textProperties.length == 0) {
      return;
    }

    for (TextProperties oldText in _oldTextProperties) {
      for (TextProperties text in _textProperties) {
        if (!text._isMoving &&
            !oldText._isMoving &&
            text.text == oldText.text) {
          oldText.toX = text.offsetX;
          text._isMoving = true;
          oldText._isMoving = true;
        }
      }
    }
  }

  TextProperties morphingText(TextProperties textProperties) {
    return textProperties.copyWith(
      offsetY: 0,
      opacity: 1,
      offsetX: textProperties.offsetX -
          ((textProperties.offsetX - textProperties.toX) * progress),
    );
  }

  TextProperties incomingText(TextProperties textProperties);

  TextProperties outgoingText(TextProperties textProperties);
}

class TextProperties {
  String text;
  double offsetX;
  double offsetY;
  double width;
  double height;
  double toX;
  double opacity;
  bool _isMoving = false;
  TextProperties({
    this.text,
    this.offsetX = 0,
    this.offsetY = 0,
    this.width,
    this.height,
    this.toX = 0,
    this.opacity = 1,
  });

  TextProperties copyWith({
    String text,
    double offsetX,
    double offsetY,
    double width,
    double height,
    double toX,
    double opacity,
    bool isMoving,
  }) {
    return TextProperties(
      text: text ?? this.text,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      width: width ?? this.width,
      height: height ?? this.height,
      toX: toX ?? this.toX,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  String toString() {
    return 'TextProperties(text: $text, offsetX: $offsetX, offsetY: $offsetY, width: $width, height: $height, toX: $toX, opacity: $opacity, isMoving: $_isMoving)';
  }
}
