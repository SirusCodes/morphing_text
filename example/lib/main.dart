import 'package:flutter/material.dart';

import 'package:morphing_text/morphing_text.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morhing text',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<String> text = [
    "Design",
    "Design is not just",
    "what it looks like",
    "and feels like.",
    "Design",
    "Design is how it works.",
    "- Steve Jobs",
  ];

  List<Widget> animations = [
    ScaleMorphingText(
      texts: text,
      loopForever: true,
      onComplete: () {
        print("Completed");
      },
      textStyle: TextStyle(fontSize: 50.0),
    ),
    EvaporateMorphingText(
      texts: text,
      loopForever: true,
      onComplete: () {
        print("Completed");
      },
      textStyle: TextStyle(fontSize: 50.0),
    ),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: animations[index % animations.length],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            index++;
          });
        },
        child: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
