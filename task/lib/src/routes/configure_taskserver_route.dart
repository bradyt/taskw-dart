import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class ConfigureTaskserverRoute extends StatelessWidget {
  const ConfigureTaskserverRoute(this.profile);

  final String profile;

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

  @override
  Widget build(BuildContext context) {
    var alias = ProfilesWidget.of(context).profilesMap[profile];

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
              icon: Icon(Icons.show_chart),
              onPressed: () => _showStatistics(context),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          TaskrcWidget(profile),
          for (var key in [
            'taskd.ca',
            'taskd.cert',
            'taskd.key',
          ])
            ListTile(
              title: Text(key),
              onTap: () => setConfig(profile: profile, key: key),
            ),
        ],
      ),
    );
  }
}

class TaskrcWidget extends StatefulWidget {
  const TaskrcWidget(this.profile);

  final String profile;

  @override
  _TaskrcWidgetState createState() => _TaskrcWidgetState();
}

class _TaskrcWidgetState extends State<TaskrcWidget> {
  String? server;
  String? address;
  String? port;
  Credentials? credentials;
  bool hideKey = true;

  @override
  void initState() {
    super.initState();
    _getConfig().catchError(
      (_) {
        server = '';
        setState(() {});
      },
      test: (e) => e is FileSystemException,
    );
  }

  Future<void> _getConfig() async {
    var dir = await getApplicationDocumentsDirectory();
    var config = Profiles(dir).getStorage(widget.profile).getConfig();
    server = config['taskd.server'];
    credentials = Credentials.fromString(config['taskd.credentials']);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var credentialsString = '';
    if (credentials != null) {
      String key;
      if (hideKey) {
        key = credentials!.key.replaceAll(RegExp(r'[0-9a-f]'), '*');
      } else {
        key = credentials!.key;
      }

      credentialsString = '${credentials!.org}/${credentials!.user}/$key';
    }

    return ExpansionTile(
      title: Text('.taskrc'),
      children: [
        ListTile(
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                'taskd.server=$server',
                style: GoogleFonts.firaMono(),
              ),
            ),
            onTap: (server == null || server!.isEmpty)
                ? null
                : () async {
                    var parts = server!.split(':').first.split('.');
                    var length = parts.length;
                    var mainDomain =
                        parts.sublist(length - 2, length).join('.');

                    ProfilesWidget.of(context).renameProfile(
                      profile: widget.profile,
                      alias: mainDomain,
                    );
                  }),
        ListTile(
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              'taskd.credentials=$credentialsString',
              style: GoogleFonts.firaMono(),
            ),
          ),
          trailing: (credentials == null)
              ? null
              : IconButton(
                  icon: Icon(hideKey ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    hideKey = !hideKey;
                    setState(() {});
                  },
                ),
        ),
        ListTile(
            title: Text('Select .taskrc'),
            onTap: () async {
              await setConfig(profile: widget.profile, key: '.taskrc');
              await _getConfig();
            }),
      ],
    );
  }
}
