import 'dart:async';

import 'package:flutter/material.dart';

import 'core/custom_morphing_text.dart';

class EvaporateMorphingText extends StatefulWidget {
  /// List of [String] which will show the texts
  final List<String> texts;

  /// Gives [TextStyle] to the text
  ///
  /// Default is [DefaultTextStyle]
  final TextStyle? textStyle;

  /// Speed of changing text
  ///
  /// Default is [Duration(milliseconds: 500)]
  final Duration speed;

  /// Duration of pause between the changing text
  ///
  /// Default is [Duration(seconds: 1, milliseconds: 500)]
  final Duration pause;

  /// Animation should keep looping forever
  ///
  /// Default is [false]
  final bool loopForever;

  /// Number of times animation should repeat
  /// after the defined [loopCount] is completed
  /// [onCompleted] is called.
  ///
  /// Default is [1]
  final int loopCount;

  /// Called after [loopCount] is completed
  final VoidCallback? onComplete;

  /// Curve which controls opacity from 0 to 1
  ///
  /// Default is [Curves.easeInCubic]
  final Curve fadeInCurve;

  /// Curve which controls opacity from 1 to 0
  ///
  /// Default is [Curves.easeInCubic]
  final Curve fadeOutCurve;

  /// Curve which controls movement of text and scale changes
  ///
  /// Default is [Curves.easeIn]
  final Curve progressCurve;

  /// This will give the displacement factor of y-axis of the text
  ///
  /// Default is [1.0]
  final double yDisplacement;

  const EvaporateMorphingText({
    Key? key,
    required this.texts,
    this.textStyle,
    this.speed = const Duration(milliseconds: 500),
    this.pause = const Duration(seconds: 1, milliseconds: 500),
    this.loopForever = false,
    this.loopCount = 1,
    this.onComplete,
    this.fadeInCurve = Curves.easeInCubic,
    this.fadeOutCurve = Curves.easeInCubic,
    this.progressCurve = Curves.easeIn,
    this.yDisplacement = 1.0,
  })  : assert(
          loopCount > 0,
          "'loopCount' should have value greater than 0",
        ),
        super(key: key);

  @override
  _EvaporateMorphingTextState createState() => _EvaporateMorphingTextState();
}

class _EvaporateMorphingTextState extends State<EvaporateMorphingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn, _fadeOut, _progress;

  late List<String> texts;
  int index = -1;
  late int length, count;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Setting up controller and animation
    _controller = AnimationController(
      vsync: this,
      duration: widget.speed,
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: widget.fadeInCurve);
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.fadeOutCurve),
    );
    _progress =
        CurvedAnimation(parent: _controller, curve: widget.progressCurve)
          ..addStatusListener(_statusListener);

    // getting data from parent class
    texts = widget.texts;
    length = texts.length;
    count = widget.loopCount;

    // Calling _nextText to start animation
    _nextText();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return CustomMorphingText(
          morphingText: CustomEvaporateMorphingText(
            text: texts[index],
            textStyle:
                DefaultTextStyle.of(context).style.merge(widget.textStyle),
            fadeInProgress: _fadeIn.value,
            fadeOutProgress: _fadeOut.value,
            progress: _progress.value,
            yDisplace: widget.yDisplacement,
          ),
        );
      },
    );
  }

  void _statusListener(AnimationStatus status) {
    if (AnimationStatus.completed == status) {
      // Pause before starting an animation and then call _nextText
      _timer = Timer(widget.pause, _nextText);
    }
  }

  void _nextText() {
    final bool isLast = index >= length - 1;

    // loopForever is [false] and  we are a last index
    if (!widget.loopForever && isLast) {
      // decrement the count
      count--;
      // check if the counter is [0]
      if (count == 0) {
        // call [onComplete] and break the recusive calls
        widget.onComplete?.call();
        return;
      }
    }

    // incremented index or set to [0]
    index = isLast ? 0 : index + 1;

    if (mounted) setState(() {});

    _controller.forward(from: 0);
  }
}

class CustomEvaporateMorphingText extends MorphingText {
  CustomEvaporateMorphingText({
    required String text,
    required TextStyle textStyle,
    required double progress,
    required this.fadeInProgress,
    required this.fadeOutProgress,
    required this.yDisplace,
  }) : super(text, textStyle, progress);

  /// Opacity of text which will come next
  final double fadeInProgress;

  /// Opacity of text which is going out
  final double fadeOutProgress;

  /// Displacement of text in y-axis
  final double yDisplace;

  @override
  TextProperties incomingText(TextProperties textProperties) {
    return textProperties.copyWith(
      offsetY: yDisplace * textProperties.height! * (1 - progress),
      opacity: fadeInProgress,
    );
  }

  @override
  TextProperties outgoingText(TextProperties textProperties) {
    return textProperties.copyWith(
      offsetY: -(yDisplace * textProperties.height! * (progress)),
      opacity: fadeOutProgress,
    );
  }
}
