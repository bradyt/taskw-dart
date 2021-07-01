import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'package:taskc/storage.dart';

import 'package:task/task.dart';

void showExceptionDialog({context, e, trace}) {
  stdout.writeln(e);
  if (e.runtimeType == BadCertificateException) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: SelectableText('${e.runtimeType}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '''
sha1: ${sha1.convert(e.certificate.sha1)}

The server sent a certificate that could not be verified with your CA file.

You may export and inspect the certificate. You may indicate that you trust the
certificate, and it will be saved to this profile to allow future
connections.'''
                  .replaceAll(RegExp(r'(?<!\n)\n(?!\n)'), ' '),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Storage(e.profile).addFileContents(
                key: 'server.cert',
                contents: e.certificate.pem,
              );
              Navigator.of(context).pop();
            },
            child: Text('Trust'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () async {
              await saveServerCert(e.certificate.pem);
              Navigator.of(context).pop();
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
    return;
  }
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
