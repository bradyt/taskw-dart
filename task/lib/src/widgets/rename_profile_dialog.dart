import 'package:flutter/material.dart';

import 'package:task/task.dart';

class RenameProfileDialog extends StatelessWidget {
  const RenameProfileDialog({
    required this.profile,
    required this.alias,
    required this.context,
  });

  final String profile;
  final String? alias;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController(text: alias);

    return AlertDialog(
      scrollable: true,
      title: Text('Rename profile'),
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
            ProfilesWidget.of(context).renameProfile(
              profile: profile,
              alias: controller.text,
            );
            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
