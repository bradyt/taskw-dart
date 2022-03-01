// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ignore_for_file: avoid_types_on_closure_parameters
// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uuid/uuid.dart';

import 'package:taskj/json.dart';
import 'package:taskw/taskw.dart';

import 'package:task/main.dart';
import 'package:task/task.dart';

void main() {
  testWidgets('simple home page test', (WidgetTester tester) async {
    var testingDirectory = Directory('test/profiles/${const Uuid().v1()}')
      ..createSync(recursive: true);
    await tester.pumpWidget(
      ProfilesWidget(
        baseDirectory: testingDirectory,
        child: TaskApp(),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
  });
  testWidgets('test task list item', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TaskListItem(
            Task(
              (b) => b
                ..status = 'pending'
                ..uuid = const Uuid().v1()
                ..entry = DateTime.now()
                ..description = 'foo',
            ),
          ),
        ),
      ),
    );
  });
  testWidgets('test project column', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ProjectsColumn(
            {
              'a': ProjectNode(),
            },
            'foo',
            (_) {},
          ),
        ),
      ),
    );
    await tester.tap(find.text('project:foo'));
    await tester.pump();
    expect(find.text('a'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });
}
