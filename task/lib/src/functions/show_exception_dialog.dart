import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskc/storage.dart';

import 'package:task/task.dart';

void showExceptionDialog({context, e, trace}) {
  if (e.runtimeType == BadCertificateException) {
    String identifier;
    try {
      var re = RegExp(r'(^-----[^-]+-----$)([^-]*)', multiLine: true);
      var normalized =
          re.firstMatch(e.certificate.pem)?.group(2)?.replaceAll('\n', '');
      var bytes = base64.decode(normalized!);
      var sha1Digest = sha1.convert(bytes);
      identifier = 'SHA-1: $sha1Digest';
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
$identifier

The server sent a certificate that could not be verified with your CA file.

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
      content: SelectableText(
        '$e${trace != null ? '\n$trace' : ''}',
        style: GoogleFonts.firaMono(),
      ),
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
