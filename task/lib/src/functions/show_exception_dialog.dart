import 'package:flutter/material.dart';

void showExceptionDialog({context, e}) {
  print(e);
  print('${e.runtimeType}');
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: SelectableText('${e.runtimeType}'),
      content: SelectableText('$e'),
      actions: [
        ElevatedButton(
          child: Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}
