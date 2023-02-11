import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  @override
  var questionIndex = 0;

  void answerQuestion() {
    setState(() {
      questionIndex = questionIndex + 1;
    });

    print(questionIndex);
  }

  var questions = [
    "What animal do you like ?",
    "what is your favorite color ?"
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text("Exam"),
        centerTitle: true,
        titleTextStyle:
            TextStyle(color: Color.fromARGB(255, 65, 65, 30), fontSize: 19),
      ),
      body: Column(
        children: [
          Text(
            questions[questionIndex],
            textAlign: TextAlign.center,
          ),
          ElevatedButton(onPressed: answerQuestion, child: Text("Answer 1")),
          ElevatedButton(onPressed: answerQuestion, child: Text("Answer 2")),
          ElevatedButton(onPressed: answerQuestion, child: Text("Answer 3")),
        ],
      ),
    ));
  }
}
