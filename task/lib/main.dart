import 'package:flutter/material.dart';

import 'package:task/task.dart';

void main() {
  runApp(TaskApp());
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'task',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      home: ProfilesRoute(),
    );
  }
}
