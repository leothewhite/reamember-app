import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

// var wordBox;
late Box wordBox;


void main() async {
  await Hive.initFlutter();
  wordBox = await Hive.openBox('wordBox');
  runApp(const ReaApp());
}

String _totalMessage = "";
String _word = "";
List<dynamic> _searchedDefinition = [];


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

Future<Map<String, dynamic>> searchWord(String word) async {
  log("word: $word");

  String key = await File('/Users/gina/AndroidStudioProjects/reamember-app/lib/key.txt').readAsString();
  http.Response res = await http.get(Uri.parse(
      'https://stdict.korean.go.kr/api/search.do?certkey_no=7181&key=$key&q=$word&req_type=json'));

  var data;

  if (res.body == "") {
    log("NO!");
    data = {"error": "failed"};
  } else {
    data = jsonDecode(res.body);
  }

  return data;
}

Future<Map<String, dynamic>> deepSearchWord(String code) async {
  String key = await File('/Users/gina/AndroidStudioProjects/reamember-app/lib/key.txt').readAsString();
  http.Response res = await http.get(Uri.parse(
      'https://stdict.korean.go.kr/api/view.do?certkey_no=7181&key=$key&method=target_code&q=$code&req_type=json'));

  var data;

  if (res.body == "") {
    log("NO!");
    data = {"error": "failed"};
  } else {
    data = jsonDecode(res.body);
  }

  return data;
}

class _ReaHomePageState extends State<ReaHomePage> {
  final TextEditingController _textController = TextEditingController();
  String inputText = '';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("\n\n\n\n"),
              SizedBox(
                width: 100,
                child: TextField(
                    controller: _textController
                ),
              ),
              FilledButton(onPressed: () async {
                setState(() {
                  _searchedDefinition = [];
                  _word = "";
                });

                log('clicked');

                _word = _textController.text;
                var searchResult = await searchWord(_word);

                try {
                  searchResult['channel'];
                  setState(() {
                    _totalMessage = "$_word에 대한 ${searchResult['channel']['total'].toString()}개의 검색 결과\n";
                  });
                  _searchedDefinition = searchResult['channel']['item'];
                } catch(e) {
                  setState(() {
                    _totalMessage = "단어 $_word를 찾을 수 없습니다.";
                  });
                }
              }, child: const Text("단어 검색")),
              Text(_totalMessage),
              Column(
                children: [
                  // 클릭된 단어 코드 불러오기
                  for (var value in _searchedDefinition) TextButton(onPressed: () async {
                    SnackBar snackBar;
                    if (!wordBox.containsKey(value['target_code'])) {
                      Map<String, dynamic> data = await deepSearchWord(value['target_code']);
                      wordBox.put(value['target_code'], data);
                      snackBar = SnackBar(content: Text("단어 \"$_word\"을/를 추가했습니다."), action: null);
                    } else {
                      snackBar = SnackBar(content: Text("단어 \"$_word\"는 이미 추가되어 있습니다."), action: null);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    log(value['target_code']);
                  }, child: Text(value['sense']['definition']+'\n'))
                ],
              )
            ],
          )
        )
      ),
    );
  }
}


