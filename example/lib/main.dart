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
  List<String> text = [
    "Design",
    "Design is not just",
    "what it looks like",
    "and feels like.",
    "Design",
    "Design is how it works.",
    "- Steve Jobs",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ScaleMorphingText(
          texts: text,
          loopForever: true,
          onComplete: () {
            print("Completed");
          },
          textStyle: TextStyle(fontSize: 40.0),
        ),
      ),
    );
  }
}
