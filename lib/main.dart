import 'package:flutter/material.dart';

void main() {
  runApp(const ReaApp());
}

class ReaApp extends StatelessWidget {
  const ReaApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reamember',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ReaHomePage(title: 'Reamember Demo'),
    );
  }
}

class ReaHomePage extends StatefulWidget {
  const ReaHomePage({super.key, required this.title});

  final String title;

  @override
  State<ReaHomePage> createState() => _ReaHomePageState();
}

class _ReaHomePageState extends State<ReaHomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Hello, World!'),
        ],
      ),
    );
  }
}
