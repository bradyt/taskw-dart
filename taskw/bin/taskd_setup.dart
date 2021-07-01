// ignore_for_file: avoid_print

import 'package:args/args.dart';

import 'package:taskw/taskd.dart';

Future<void> main(List<String> args) async {
  var parser = ArgParser()
    ..addFlag('help',
        abbr: 'h', negatable: false, help: 'Displays this help information.')
    ..addOption('binding-address', abbr: 'b', defaultsTo: 'localhost')
    ..addOption('client-address', abbr: 'a', defaultsTo: 'localhost')
    ..addOption('TASKDDATA', abbr: 't')
    ..addOption('HOME', abbr: 'H');

  var results = parser.parse(args);

  if (results['help']) {
    print(parser.usage);
  } else {
    print('running setup script...');

    var taskd = Taskd(results['TASKDDATA']);
    await taskd.initialize();
    await taskd.setAddressAndPort(
      address: results['binding-address'],
      port: 53589,
    );
    var userKey = await taskd.addUser('First Last');
    await taskd.initializeClient(
      home: results['HOME'],
      address: results['client-address'],
      port: 53589,
      userKey: userKey,
      fileName: 'first_last',
      fullName: 'First Last',
    );

    print('done');
  }
}
