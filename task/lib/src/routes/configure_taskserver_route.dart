import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pem/pem.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:taskc/storage.dart';
import 'package:taskc/taskrc.dart';

import 'package:task/task.dart';

class ConfigureTaskserverRoute extends StatelessWidget {
  const ConfigureTaskserverRoute(this.storage, {Key? key}) : super(key: key);

  final Storage storage;

  Future<void> _setConfigurationFromFixtureForDebugging() async {
    var contents = await rootBundle.loadString('assets/.taskrc');
    storage.taskrc.addTaskrc(contents);
    for (var entry in {
      'taskd.certificate': '.task/first_last.cert.pem',
      'taskd.key': '.task/first_last.key.pem',
      'taskd.ca': '.task/ca.cert.pem',
      // 'server.cert': '.task/server.cert.pem',
    }.entries) {
      var contents = await rootBundle.loadString('assets/${entry.value}');
      storage.guiPemFiles.addPemFile(
        key: entry.key,
        contents: contents,
        name: entry.value.split('/').last,
      );
    }
  }

  Future<void> _showStatistics(BuildContext context) async {
    await storage.home.statistics(await client()).then(
      (header) {
        var maxKeyLength =
            header.keys.map<int>((key) => (key as String).length).reduce(max);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            title: const Text('Statistics:'),
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
                child: const Text('Ok'),
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
        ProfilesWidget.of(context).setState(() {});
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
              icon: const Icon(Icons.bug_report),
              onPressed: _setConfigurationFromFixtureForDebugging,
            ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.show_chart),
              onPressed: () => _showStatistics(context),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          TaskrcWidget(profile),
          for (var pem in [
            'taskd.certificate',
            'taskd.key',
            'taskd.ca',
          ])
            PemWidget(
              storage: storage,
              pem: pem,
            ),
          if (StorageWidget.of(context).serverCertExists)
            PemWidget(
              storage: storage,
              pem: 'server.cert',
            ),
        ],
      ),
    );
  }
}

class PemWidget extends StatefulWidget {
  const PemWidget({required this.storage, required this.pem, Key? key})
      : super(key: key);

  final Storage storage;
  final String pem;

  @override
  State<PemWidget> createState() => _PemWidgetState();
}

class _PemWidgetState extends State<PemWidget> {
  @override
  Widget build(BuildContext context) {
    var contents = widget.storage.guiPemFiles.pemContents(widget.pem);
    var name = widget.storage.guiPemFiles.pemFilename(widget.pem);
    return ListTile(
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          '${widget.pem.padRight(17)}${(widget.pem == 'server.cert') ? '' : ' = $name'}',
          style: GoogleFonts.firaMono(),
        ),
      ),
      subtitle: (key) {
        if (key == 'taskd.key' || contents == null) {
          return null;
        }
        try {
          var fingerprints = decodePemBlocks(PemLabel.certificate, contents)
              .map((block) => 'SHA-1: ${sha1.convert(block)}'.toUpperCase())
              .join('\n');
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              fingerprints,
              style: GoogleFonts.firaMono(),
            ),
          );
          // ignore: avoid_catches_without_on_clauses
        } catch (e) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              '${e.runtimeType}',
              style: GoogleFonts.firaMono(),
            ),
          );
        }
      }(widget.pem),
      onTap: (widget.pem == 'server.cert')
          ? () {
              widget.storage.guiPemFiles.removeServerCert();
              ProfilesWidget.of(context).setState(() {});
              setState(() {});
            }
          : () async {
              await setConfig(storage: widget.storage, key: widget.pem);
              setState(() {});
            },
      onLongPress: (widget.pem == 'taskd.ca' && name != null)
          ? () {
              widget.storage.guiPemFiles.removeTaskdCa();
              setState(() {});
            }
          : null,
    );
  }
}

class TaskrcWidget extends StatefulWidget {
  const TaskrcWidget(this.profile, {Key? key}) : super(key: key);

  final String profile;

  @override
  State<TaskrcWidget> createState() => _TaskrcWidgetState();
}

class _TaskrcWidgetState extends State<TaskrcWidget> {
  Server? server;
  Credentials? credentials;
  bool hideKey = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getConfig().catchError(
      (_) {
        setState(() {});
      },
      test: (e) => e is FileSystemException,
    );
  }

  Future<void> _getConfig() async {
    var taskrc = ProfilesWidget.of(context).getStorage(widget.profile).taskrc;
    server = taskrc.server();
    credentials = taskrc.credentials();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String? credentialsString;
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
      title: Text(
        'TASKRC',
        style: GoogleFonts.firaMono(),
      ),
      children: [
        ListTile(
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                'taskd.server      = $server',
                style: GoogleFonts.firaMono(),
              ),
            ),
            onTap: (server == null)
                ? null
                : () async {
                    var parts = server!.address.split('.');
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
              'taskd.credentials = $credentialsString',
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
            title: Text(
              'Select TASKRC',
              style: GoogleFonts.firaMono(),
            ),
            onTap: () async {
              await setConfig(
                storage: ProfilesWidget.of(context).getStorage(widget.profile),
                key: 'TASKRC',
              );

              await _getConfig();
            }),
      ],
    );
  }
}
