import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';

import 'package:taskw/taskw.dart';

import 'package:taskc/taskc.dart';

class TaskListRoute extends StatefulWidget {
  @override
  _TaskListRouteState createState() => _TaskListRouteState();
}

class _TaskListRouteState extends State<TaskListRoute> {
  List<Task> tasks;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      tasks = Storage(dir).listTasks();
      setState(() {});
    });
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('Add task'),
        content: TextField(),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Submit'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('task list'),
      ),
      body: ListView(
        children: [
          if (tasks != null)
            for (var task in tasks)
              Card(
                child: ListTile(
                  title: Text('${task.description}'),
                ),
              ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add task',
        child: Icon(Icons.add),
      ),
    );
  }
}
