import 'package:flutter/material.dart';
import 'package:videocompass/pages/Home.dart';
void main() {
  runApp(MyApp());
  
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
      theme: ThemeData(), debugShowCheckedModeBanner: false, home: Home());
}
