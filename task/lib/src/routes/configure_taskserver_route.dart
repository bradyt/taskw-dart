import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class ConfigureTaskserverRoute extends StatelessWidget {
  ConfigureTaskserverRoute(this.profile, this.alias);

  final String profile;
  final String alias;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(alias ?? profile),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: Icon(Icons.bug_report),
              onPressed: () {
                getApplicationDocumentsDirectory().then((dir) async {
                  var storage = Profiles(dir).getStorage(profile);
                  for (var entry in {
                    '.taskrc': '.taskrc',
                    'taskd.ca': '.task/ca.cert.pem',
                    'taskd.cert': '.task/first_last.cert.pem',
                    'taskd.key': '.task/first_last.key.pem',
                  }.entries) {
                    var contents = await rootBundle
                        .loadString('../fixture/${entry.value}');
                    storage.addFileContents(
                      key: entry.key,
                      contents: contents,
                    );
                  }
                });
              },
            ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                getApplicationDocumentsDirectory().then((dir) {
                  var map = Profiles(dir).getStorage(profile).getConfig();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        'taskd.server:      ${map['taskd.server']}\n'
                        'taskd.credentials: ${map['taskd.credentials']}',
                        style: GoogleFonts.firaMono(),
                      ),
                    ),
                  ));
                });
              },
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.show_chart),
              onPressed: () {
                getApplicationDocumentsDirectory().then((dir) {
                  Profiles(dir).getStorage(profile).statistics().then(
                    (header) {
                      var maxKeyLength = header.keys
                          .map((key) => key.length)
                          .reduce((a, b) => max(a as int, b as int));
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          scrollable: true,
                          title: Text('Statistics:'),
                          content: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var key in header.keys.toList())
                                      Text(
                                        '${'$key:'.padRight(maxKeyLength + 1)} ${header[key]}',
                                        style: GoogleFonts.firaMono(),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                    },
                    onError: (e) {
                      showExceptionDialog(
                        context: context,
                        e: e,
                      );
                    },
                  );
                });
              },
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          for (var key in [
            '.taskrc',
            'taskd.ca',
            'taskd.cert',
            'taskd.key',
          ])
            ListTile(
              title: Text(key),
              onTap: () {
                FilePickerWritable().openFile((_, file) async {
                  var contents = file.readAsStringSync();
                  getApplicationDocumentsDirectory().then((dir) {
                    Profiles(dir)
                        .getStorage(profile)
                        .addFileContents(key: key, contents: contents);
                  });
                });
              },
            ),
        ],
      ),
    );
  }
}
