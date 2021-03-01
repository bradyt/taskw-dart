import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskc/taskc.dart';

import 'package:taskw/taskw.dart';

import 'package:task/task.dart';

class ConfigureTaskserverRoute extends StatelessWidget {
  const ConfigureTaskserverRoute(this.storage);

  final Storage storage;

  Future<void> _setConfigurationFromFixtureForDebugging() async {
    for (var entry in {
      '.taskrc': '.taskrc',
      'taskd.ca': '.task/ca.cert.pem',
      'taskd.cert': '.task/first_last.cert.pem',
      'taskd.key': '.task/first_last.key.pem',
      'server.cert': '.task/server.cert.pem',
    }.entries) {
      var contents = await rootBundle.loadString('../fixture/${entry.value}');
      storage.addFileContents(
        key: entry.key,
        contents: contents,
      );
    }
  }

  Future<void> _showStatistics(BuildContext context) async {
    await storage.statistics().then(
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
    var profile = storage.profile.uri.pathSegments.lastWhere(
      (segment) => segment.isNotEmpty,
    );
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
              onTap: () => setConfig(storage: storage, key: key),
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getConfig().catchError(
      (_) {
        server = '';
        setState(() {});
      },
      test: (e) => e is FileSystemException,
    );
  }

  Future<void> _getConfig() async {
    var config =
        ProfilesWidget.of(context).getStorage(widget.profile).getConfig();
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
              await setConfig(
                storage: ProfilesWidget.of(context).getStorage(widget.profile),
                key: '.taskrc',
              );

              await _getConfig();
            }),
      ],
    );
  }
}
