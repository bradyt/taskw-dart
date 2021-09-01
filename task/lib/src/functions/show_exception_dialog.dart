import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:pem/pem.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskc/storage.dart';

import 'package:task/task.dart';

void showExceptionDialog({context, e, trace}) {
  if (e.runtimeType == BadCertificateException) {
    String identifier;
    try {
      identifier = decodePemBlocks(PemLabel.certificate, e.certificate.pem)
          .map((block) => 'SHA-1: ${sha1.convert(block)}'.toUpperCase())
          .join('\n');
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
              Storage(e.home).home.addPemFile(
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
