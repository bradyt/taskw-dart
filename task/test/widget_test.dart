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
              'a': ProjectNode()..children = {'a.b'},
              'a.b': ProjectNode()..parent = 'a',
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

    await tester.ensureVisible(find.text('a'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('a'));

    expect(find.text('a.b'), findsOneWidget);
    await tester.tap(find.text('a.b'));
  });
  testWidgets('test tag filter wrap', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TagFiltersWrap(
            TagFilters(
              tagUnion: false,
              toggleTagUnion: () {},
              tags: {'a': TagFilterMetadata(display: 'a', selected: false)},
              toggleTagFilter: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(find.text('AND'), findsOneWidget);
    await tester.tap(find.text('AND'));
    expect(find.text('a'), findsOneWidget);
    await tester.tap(find.text('a'));
  });
  testWidgets('test task list view', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: TaskListView(
            taskData: [
              Task(
                (b) => b
                  ..status = 'pending'
                  ..uuid = const Uuid().v1()
                  ..entry = DateTime.now()
                  ..description = 'foo',
              ),
            ],
            pendingFilter: true,
          ),
        ),
      ),
    );
    expect(find.text('foo'), findsOneWidget);
    await tester.tap(find.text('foo'));
  });
  testWidgets('test filter drawer', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: FilterDrawer(
            Filters(
              pendingFilter: true,
              togglePendingFilter: () {},
              projects: <String, ProjectNode>{},
              toggleProjectFilter: (_) {},
              projectFilter: '',
              tagFilters: TagFilters(
                tags: {},
                toggleTagFilter: (_) {},
                tagUnion: false,
                toggleTagUnion: () {},
              ),
            ),
          ),
        ),
      ),
    );
  });
  testWidgets('test queries column', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: QueriesColumn(const [], () {}),
        ),
      ),
    );
  });
  testWidgets('test queries expansion tile', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: QueryExpansionTile(
            QueryUI(
              uuid: 'foo',
              selectedUuid: 'bar',
              select: () {},
              rename: () {},
              delete: () {},
            ),
          ),
        ),
      ),
    );
    expect(find.byType(Radio<String>), findsOneWidget);
    await tester.tap(find.byType(Radio<String>));
  });
  testWidgets('test select profile widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SelectProfile(
            'foo',
            const {
              'foo': null,
              'bar': null,
            },
            (_) {},
          ),
        ),
      ),
    );
    expect(find.byType(ExpansionTile), findsOneWidget);
    await tester.tap(find.text('Select profile'));
    await tester.pumpAndSettle();
    expect(find.byType(Radio<String>), findsNWidgets(2));
    expect(find.widgetWithText(ListTile, 'bar'), findsOneWidget);
    expect(
        find.descendant(
            of: find.widgetWithText(ListTile, 'bar'),
            matching: find.byType(Radio<String>)),
        findsOneWidget);
    await tester.tap(find.descendant(
        of: find.widgetWithText(ListTile, 'bar'),
        matching: find.byType(Radio<String>)));
  });
  testWidgets('test manage profile widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ManageProfile(
            () {},
            () {},
            () {},
            () {},
            () {},
          ),
        ),
      ),
    );
  });
}
