import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

import 'package:taskj/json.dart';
import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class AddTaskDialog extends StatelessWidget {
  const AddTaskDialog({Key? key}) : super(key: key);

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
            try {
              validateTaskDescription(controller.text);
              var now = DateTime.now().toUtc();
              StorageWidget.of(context).mergeTask(
                Task(
                  (b) => b
                    ..status = 'pending'
                    ..uuid = Uuid().v1()
                    ..entry = now
                    ..description = controller.text
                    ..modified = now,
                ),
              );
              Navigator.of(context).pop();
            } on FormatException catch (e, trace) {
              showExceptionDialog(
                context: context,
                e: e,
                trace: trace,
              );
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
