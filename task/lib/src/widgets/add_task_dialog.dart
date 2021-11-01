import 'package:flutter/material.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class AddTaskDialog extends StatelessWidget {
  const AddTaskDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();

    return AlertDialog(
      scrollable: true,
      title: const Text('Add task'),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              validateTaskDescription(controller.text);
              StorageWidget.of(context).mergeTask(
                taskParser(controller.text),
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
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
