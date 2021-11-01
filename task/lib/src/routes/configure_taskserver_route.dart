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
    for (var entry in {
      '.taskrc': '.taskrc',
      'taskd.ca': '.task/ca.cert.pem',
      'taskd.cert': '.task/first_last.cert.pem',
      'taskd.key': '.task/first_last.key.pem',
      // 'server.cert': '.task/server.cert.pem',
    }.entries) {
      var contents = await rootBundle.loadString('assets/${entry.value}');
      storage.home.addPemFile(
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
            'taskd.ca',
            'taskd.cert',
            'taskd.key',
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
    var contents = widget.storage.home.pemContents(widget.pem);
    var name = widget.storage.home.pemFilename(widget.pem);
    return ListTile(
      title: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          '${widget.pem.padRight(10)}${(widget.pem == 'server.cert') ? '' : ' = $name'}',
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
              widget.storage.home.removeServerCert();
              ProfilesWidget.of(context).setState(() {});
              setState(() {});
            }
          : () async {
              await setConfig(storage: widget.storage, key: widget.pem);
              setState(() {});
            },
      onLongPress: (widget.pem == 'taskd.ca' && name != null)
          ? () {
              widget.storage.home.removeTaskdCa();
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
    var config =
        ProfilesWidget.of(context).getStorage(widget.profile).home.getConfig();
    var taskrc = Taskrc.fromMap(config);
    server = taskrc.server;
    credentials = taskrc.credentials;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var credentialsString;
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
      title: const Text('.taskrc'),
      children: [
        ListTile(
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                'taskd.server=$server',
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
            title: const Text('Select .taskrc'),
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
