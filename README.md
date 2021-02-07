<div>
   <a href="https://github.com/SirusCodes/morphing_text/blob/master/LICENSE">
   <img src="https://img.shields.io/github/license/SirusCodes/morphing_text" >
   </a>

   <a href="https://pub.dev/packages/morphing_text">
   <img src="https://img.shields.io/pub/v/morphing_text" >
   </a>

   <a href="https://github.com/SirusCodes/morphing_text/issues">
   <img src="https://img.shields.io/github/issues/SirusCodes/morphing_text" >
   </a>

   <a href="https://github.com/SirusCodes/morphing_text">
   <img src="https://img.shields.io/github/stars/SirusCodes/morphing_text" >
   </a>
</div>

# Morphing Text

It is a collection of text animations inspired by [LTMorphingLabel](https://github.com/lexrus/LTMorphingLabel).

## Animations

### ScaleMorphingText

<img src="https://github.com/SirusCodes/morphing_text/blob/master/display/scale.gif?raw=true" height=200px>

```dart
ScaleMorphingText(
    texts: text,
    loopForever: true,
    onComplete: () {},
    textStyle: TextStyle(fontSize: 40.0),
),
```

### EvaporateMorphingText

<img src="https://github.com/SirusCodes/morphing_text/blob/master/display/evaporate.gif?raw=true" height=200px>

```dart
EvaporateMorphingText(
    texts: text,
    loopForever: true,
    onComplete: () {},
    yDisplacement: 1.2,     // To factor of y-displacement
    textStyle: TextStyle(fontSize: 40.0),
),
```

## All Parameters

| Type | Parameter | Description | Default |
|--|--|--|--|
| `List<String>` | texts | List of `String` which will show the text | - |
| `TextStyle` | textStyle | Styling of texts | DefaultTextStyle |
| `Duration` | speed | Define the speed of changing of each text | 500 milliseconds |
| `Duration` | pause | Define the pause between each transition | 1500 milliseconds |
| `bool` | loopForever | When `true` animations will repeat indefinitely | false |
| `int` | loopCount | Number of time animation will repeat itself | 1 |
| `void` | onComplete | When `loopCount` is completed it is called  | - |
| `Curve` | fadeInCurve | Curve which controls opacity from 0 to 1 | Curves.easeInExpo |
| `Curve` | fadeOutCurve | Curve which controls opacity from 1 to 0 | Curves.easeOut |
| `Curve` | progressCurve | Curve which controls movement of text and scale changes | Curves.easeIn |

> Changing Curves is purely experimental, select proper curves as per your need or leave them at default

## Making custom animations

1. To make custom animations extend your class with `MorphingText`

```dart
class CustomFooMorphingText extends MorphingText {
  ...
}
```
2. Override `incomingText` and `outgoingText` methods to animate entry of next and exit of previous text respectively and pass `text`, `textStyle` and `progress` to super.

```dart
class CustomFooMorphingText extends MorphingText {
  CustomFooMorphingText(
      String text,
      TextStyle textStyle,
      double progress,
  ) : super(text, textStyle, progress);

  @override
  TextProperties morphingText(TextProperties textProperties) {
    // Optional to change the motion of moving text
  }

  @override
  TextProperties incomingText(TextProperties textProperties) {
    // Write you logic for next text
  }

  @override
  TextProperties outgoingText(TextProperties textProperties) {
    // Write you logic for leaving text
  }
}
```

3. Pass your custom animation to `CustomMorphingText` in build method.

```dart
CustomMorphingText(
  morphingText: CustomFooMorphingText(
    texts[index],
    DefaultTextStyle.of(context).style.merge(widget.textStyle),
    _progress.value,
  ),
);
```

4. For example you can see implementation of `CustomScaleMorphingText` on [github](https://github.com/SirusCodes/morphing_text/blob/master/lib/src/scale.dart#L178)

## Want to Contribute?
A help is always welcomed, check our [CONTRIBUTING.md](https://github.com/SirusCodes/morphing_text/blob/master/CONTRIBUTING.md)
