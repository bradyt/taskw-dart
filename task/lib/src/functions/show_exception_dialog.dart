import 'package:flutter/material.dart';

void showExceptionDialog({context, e, trace}) {
  print(e);
  if (trace != null) {
    print(trace);
  }
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: SelectableText('${e.runtimeType}'),
      content: SelectableText('$e${(trace != null ? '\n$trace' : '')}'),
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
