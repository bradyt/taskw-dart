import 'dart:io';

import 'package:flutter/material.dart';

void showExceptionDialog({context, e, trace}) {
  stdout.writeln(e);
  if (trace != null) {
    stdout.writeln(trace);
  }
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: SelectableText('${e.runtimeType}'),
      content: SelectableText('$e${trace != null ? '\n$trace' : ''}'),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Ok'),
        ),
      ],
    ),
  );
}
