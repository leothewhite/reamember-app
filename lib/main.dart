import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:readmember/addWord.dart';


void main() async {
  runApp(const ReaApp());
}


class ReaApp extends StatelessWidget {
  const ReaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reamember',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black12),
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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text('\n\n\n\n\n'),
              OutlinedButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const addWord()));
              }, child: Text("단어 찾기"))
            ],
          )
        )
      )
    );
  }
}


