import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

late Box wordBox;
String _totalMessage = "";
String _word = "";
List<dynamic> _searchedDefinition = [];
File key_file = File('/Users/gina/AndroidStudioProjects/reamember-app/lib/key.txt');
late String key;
late SnackBar snackBar;

class addWord extends StatefulWidget {
  const addWord({super.key});

  @override
  State<StatefulWidget> createState() => addWordState();
}

class addWordState extends State<addWord> {
  final TextEditingController _textController = TextEditingController();
  String inputText = '';

  @override
  void initState() {
    initializing();

    super.initState();
  }

  @override
  void dispose() {
    _totalMessage = "";
    _word = "";
    _searchedDefinition = [];

    super.dispose();
  }


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
                  SizedBox(
                    width: 100,
                    child: TextField(
                        controller: _textController
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      _word = _textController.text;
                      var searchResult = await searchWord(_word);

                      setState(() {
                        if (isWordExists(searchResult)) {
                          _totalMessage = "$_word에 대한 ${searchResult['channel']['total'].toString()}개의 검색 결과\n";
                          _searchedDefinition = searchResult['channel']['item'];
                        } else {
                          _totalMessage = "단어 $_word를 찾을 수 없습니다.";
                        }
                      });
                    },
                  child: const Text("단어 검색")),

                  Text(_totalMessage),
                  Column(
                    children: [
                      for (var value in _searchedDefinition) TextButton(
                        onPressed: () async {
                          bool isSucceed = await saveWord(value);

                          setSnackBar(_word, isSucceed);

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        child: Text(value['sense']['definition']+'\n'))
                    ],
                  )
                ],
              )
          )
      ),
    );
  }
}

bool isWordExists(var searchResult) {
  try {
    searchResult['channel'];
    return true;
  } catch(e) {
    return false;
  }
}

void setSnackBar(String word, bool isSucceed) {
  if (isSucceed) {
    snackBar = SnackBar(content: Text("단어 \"$_word\"를(을) 추가했습니다."), action: null);
  } else {
    snackBar = SnackBar(content: Text("단어 \"$_word\"는 이미 추가되어 있습니다."), action: null);
  }
}

Future<bool> saveWord(var value) async {
  if (!wordBox.containsKey(value['target_code'])) {
    Map<String, dynamic> data = await deepSearchWord(value['target_code']);
    wordBox.put(value['target_code'], data);
    return true;
  } else {
    return false;
  }
}


void initializing() async {
  await Hive.initFlutter();
  wordBox = await Hive.openBox("wordBox");
  key = await key_file.readAsString();
}

Future<Map<String, dynamic>> searchWord(String word) async {
  log("word: $word");


  http.Response res = await http.get(Uri.parse(
      'https://stdict.korean.go.kr/api/search.do?certkey_no=7181&key=$key&q=$word&req_type=json'));

  if (res.body == "") {
    log("NO!");
    return {"error": "failed"};
  } else {
    return jsonDecode(res.body);
  }
}

Future<Map<String, dynamic>> deepSearchWord(String code) async {
  String key = await File('/Users/gina/AndroidStudioProjects/reamember-app/lib/key.txt').readAsString();
  http.Response res = await http.get(Uri.parse(
      'https://stdict.korean.go.kr/api/view.do?certkey_no=7181&key=$key&method=target_code&q=$code&req_type=json'));

  if (res.body == "") {
    return {"error": "failed"};
  } else {
    return jsonDecode(res.body);
  }
}
