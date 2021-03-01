import 'package:flutter/material.dart';

import 'package:task/task.dart';

class DeleteProfileDialog extends StatelessWidget {
  const DeleteProfileDialog({
    required this.profile,
    required this.context,
  });

  final String profile;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Text('Delete profile?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            ProfilesWidget.of(context).deleteProfile(profile);
            Navigator.of(context).pop();
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
