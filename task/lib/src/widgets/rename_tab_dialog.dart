import 'package:flutter/material.dart';

import 'package:task/task.dart';

class RenameTabDialog extends StatelessWidget {
  const RenameTabDialog({
    required this.tab,
    required this.alias,
    required this.context,
  });

  final String tab;
  final String? alias;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController(text: alias);

    return AlertDialog(
      scrollable: true,
      title: Text('Rename tab'),
      content: TextField(controller: controller),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            StorageWidget.of(context).renameTab(
              tab: tab,
              name: controller.text,
            );
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
