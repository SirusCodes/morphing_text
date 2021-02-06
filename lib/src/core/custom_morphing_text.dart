import 'package:flutter/material.dart';

class CustomMorphingText extends StatelessWidget {
  const CustomMorphingText({Key key, @required this.morphingText})
      : assert(
          morphingText is MorphingText,
          "Provider a CustomMorphingText",
        ),
        super(key: key);

  final MorphingText morphingText;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: morphingText,
      ),
    );
  }
}

abstract class MorphingText extends CustomPainter {
  MorphingText(
    this.text,
    this.textStyle,
    this.progress,
  )   : assert(text != null),
        assert(textStyle != null),
        assert(progress != null),
        assert(progress >= 0 && progress <= 1, "Should be between 0 and 1");

  /// Text which will be visible on the screen
  final String text;

  /// TextStyle of Text
  final TextStyle textStyle;

  /// Progress of animation
  ///
  /// Should be between 0 and 1
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
  bool shouldRepaint(MorphingText oldDelegate) {
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
      ..textScaleFactor = textProperties.scale
      ..textDirection = TextDirection.ltr
      ..layout();

    textPainter.paint(
      canvas,
      Offset(
        textProperties.offsetX,
        textProperties.offsetY - textPainter.height / 2,
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

      var textProperties = TextProperties()
        ..text = text[i]
        ..offsetX = forCaret.dx - textPainter.width / 2
        ..offsetY = forCaret.dy
        ..width = 0
        ..height = textPainter.height;

      list.add(textProperties);
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

  /// The motion on text which is same in current and next text
  /// in list
  ///
  /// Should return a [TextProperties]
  TextProperties morphingText(TextProperties textProperties) {
    return textProperties.copyWith(
      offsetY: 0,
      opacity: 1,
      offsetX: textProperties.offsetX -
          ((textProperties.offsetX - textProperties.toX) * progress),
    );
  }

  /// Should return [TextProperties] of text which is coming
  /// next on screen
  TextProperties incomingText(TextProperties textProperties);

  /// Should return [TextProperties] of text which is going out
  /// from screen
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
  double scale;
  bool _isMoving = false;

  TextProperties({
    this.text,
    this.offsetX = 0,
    this.offsetY = 0,
    this.width,
    this.height,
    this.toX = 0,
    this.opacity = 1,
    this.scale = 1,
  });

  TextProperties copyWith({
    String text,
    double offsetX,
    double offsetY,
    double width,
    double height,
    double toX,
    double opacity,
    double scale,
  }) {
    return TextProperties(
      text: text ?? this.text,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      width: width ?? this.width,
      height: height ?? this.height,
      toX: toX ?? this.toX,
      opacity: opacity ?? this.opacity,
      scale: scale ?? this.scale,
    );
  }

  @override
  String toString() {
    return 'TextProperties(text: $text, offsetX: $offsetX, offsetY: $offsetY, width: $width, height: $height, toX: $toX, opacity: $opacity, isMoving: $_isMoving)';
  }
}
