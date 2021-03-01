import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker_writable/file_picker_writable.dart';
import 'package:file_selector/file_selector.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class ConfigureTaskserverRoute extends StatelessWidget {
  const ConfigureTaskserverRoute(this.profile, this.alias);

  final String profile;
  final String? alias;

  Future<void> _setConfigurationFromFixtureForDebugging() async {
    var dir = await getApplicationDocumentsDirectory();
    var storage = Profiles(dir).getStorage(profile);
    for (var entry in {
      '.taskrc': '.taskrc',
      'taskd.ca': '.task/ca.cert.pem',
      'taskd.cert': '.task/first_last.cert.pem',
      'taskd.key': '.task/first_last.key.pem',
    }.entries) {
      var contents = await rootBundle.loadString('../fixture/${entry.value}');
      storage.addFileContents(
        key: entry.key,
        contents: contents,
      );
    }
  }

  Future<void> _showConfigurationFromTaskrc(BuildContext context) async {
    var dir = await getApplicationDocumentsDirectory();
    var map = Profiles(dir).getStorage(profile).getConfig();
    var server = map['taskd.server'];
    var address = server.split(':')[0];
    var port = server.split(':')[1];
    var credentials = Credentials.fromString(map['taskd.credentials']);
    var org = credentials.org;
    var user = credentials.user;
    var key = credentials.key;
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(SnackBar(
      content: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          'taskd.server.address:   $address\n'
          'taskd.server.port:      $port\n'
          'taskd.credentials.org:  $org\n'
          'taskd.credentials.user: $user\n'
          'taskd.credentials.key:  $key',
          style: GoogleFonts.firaMono(),
        ),
      ),
    ));
  }

  Future<void> _showStatistics(BuildContext context) async {
    var dir = await getApplicationDocumentsDirectory();
    await Profiles(dir).getStorage(profile).statistics().then(
      (header) {
        var maxKeyLength =
            header.keys.map<int>((key) => key.length).reduce(max);
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Ok'),
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
  }

  Future<void> _setConfig(String key) async {
    if (Platform.isMacOS) {
      var typeGroup = XTypeGroup(label: 'config', extensions: []);
      var file = await openFile(acceptedTypeGroups: [typeGroup]);
      if (file != null) {
        var contents = await file.readAsString();
        var dir = await getApplicationDocumentsDirectory();
        Profiles(dir)
            .getStorage(profile)
            .addFileContents(key: key, contents: contents);
      }
    } else {
      await FilePickerWritable().openFile((_, file) async {
        var contents = file.readAsStringSync();
        var dir = await getApplicationDocumentsDirectory();
        Profiles(dir)
            .getStorage(profile)
            .addFileContents(key: key, contents: contents);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(alias ?? profile),
        actions: [
          if (kDebugMode)
            IconButton(
              icon: Icon(Icons.bug_report),
              onPressed: _setConfigurationFromFixtureForDebugging,
            ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.info),
              onPressed: () => _showConfigurationFromTaskrc(context),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.show_chart),
              onPressed: () => _showStatistics(context),
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
              onTap: () => _setConfig(key),
            ),
        ],
      ),
    );
  }
}
