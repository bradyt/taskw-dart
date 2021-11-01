import 'dart:io';

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskc/fingerprint.dart';
import 'package:taskc/storage.dart';
import 'package:taskc/taskc_impl.dart';

import 'package:task/task.dart';

void showExceptionDialog({context, e, trace}) {
  if (e.runtimeType == BadCertificateException) {
    e as BadCertificateException;
    String identifier;
    try {
      identifier = fingerprint(e.certificate.pem).toUpperCase();
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      identifier = '${e.certificate}';
    }
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
SHA1: $identifier

The server sent a certificate that could not be verified with a CA file.

You may export and inspect the certificate. You may indicate that you trust the
certificate, and it will be saved to this profile to allow future
connections.'''
                  .replaceAll(RegExp(r'(?<!\n)\n(?!\n)'), ' '),
              style: GoogleFonts.firaMono(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Storage(e.home).guiPemFiles.addPemFile(
                    key: 'server.cert',
                    contents: e.certificate.pem,
                  );
              ProfilesWidget.of(context).setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Trust'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () async {
              await saveServerCert(e.certificate.pem);
              Navigator.of(context).pop();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
    return;
  }
  if (trace != null) {
    stdout.writeln(trace);
  }
  var content = '$e';
  if (e is TaskserverResponseException) {
    var header = e.header.cast<String, String>();
    if (header['code'] == '430' && header['status'] == 'Access denied') {
      content =
          '$content\n\nThis may be due to an issue with taskd.credentials.';
    }
  }
  if (trace != null) {
    content = '$content\n\n$trace';
  }
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: SelectableText('${e.runtimeType}'),
      content: SelectableText(
        content,
        style: GoogleFonts.firaMono(),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Ok'),
        ),
      ],
    ),
  );
}
