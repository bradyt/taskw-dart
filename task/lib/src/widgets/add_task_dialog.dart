import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import 'package:taskw/json.dart';

import 'package:task/task.dart';

class AddTaskDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();

    return AlertDialog(
      scrollable: true,
      title: Text('Add task'),
      content: TextField(
        autofocus: true,
        maxLines: null,
        controller: controller,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            var now = DateTime.now().toUtc();
            StorageWidget.of(context).mergeTask(
              Task(
                status: 'pending',
                uuid: Uuid().v1(),
                entry: now,
                description: controller.text,
                modified: now,
              ),
            );
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
