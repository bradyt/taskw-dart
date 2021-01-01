// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dcli/dcli.dart';

enum Script {
  ci,
  docker,
  local,
}

Future<void> main() async {
  print('running setup script...');
  Script script;
  if (Platform.environment['GITHUB_ACTIONS'] == 'true') {
    print('running ci setup script...');
    script = Script.ci;
    // ignore: avoid_slow_async_io
  } else if (Platform.isLinux && await File('/.dockerenv').exists()) {
    print('running docker setup script...');
    script = Script.docker;
  } else if (Platform.isMacOS || Platform.isLinux) {
    print('running local setup script...');
    script = Script.local;
  }
  await setup(script: script);
  print('done');
}

Future<void> setup({
  Script script,
}) async {
  var taskddata = (script == Script.ci) ? '/var/taskd' : 'var/taskd';
  var address = (script == Script.docker) ? '0.0.0.0' : 'localhost';
  var fixture = '.';

  env['TASKDDATA'] = taskddata;
  env['HOME'] = fixture;

  // toc: https://taskwarrior.org/docs/taskserver/setup.html

  // 3: https://taskwarrior.org/docs/taskserver/configure.html

  if (!exists(taskddata)) {
    createDir(taskddata, recursive: true);
  }
  'taskd init'.run;

  run('./generate', workingDirectory: '$fixture/pki');

  for (var pem in [
    'client.cert',
    'client.key',
    'server.cert',
    'server.key',
    'server.crl',
    'ca.cert',
  ]) {
    copy('$fixture/pki/$pem.pem', '$taskddata/$pem.pem', overwrite: true);

    'taskd config $pem $taskddata/$pem.pem'.run;
  }

  'taskd config log /dev/stdout'.run;
  'taskd config server $address:53589'.run;

  // 3: https://taskwarrior.org/docs/taskserver/control.html

  'taskd config debug.tls 2'.run;

  // 4: https://taskwarrior.org/docs/taskserver/user.html

  var org = 'Public';
  var user = 'First Last';
  String key;

  if (!exists('$taskddata/orgs/$org')) {
    'taskd add org $org'.run;
  }
  'taskd add user $org \'$user\''.forEach((line) {
    if (line.contains(': ')) {
      key = line.split(': ').last;
    }
  });

  run('./generate.client first_last', workingDirectory: '$fixture/pki');

  // 4: https://taskwarrior.org/docs/taskserver/taskwarrior.html

  if (!exists('$fixture/.task')) {
    createDir('$fixture/.task', recursive: true);
  }

  for (var pem in {
    'certificate': 'first_last.cert.pem',
    'key': 'first_last.key.pem',
    'ca': 'ca.cert.pem',
  }.entries) {
    copy('$fixture/pki/${pem.value}', '$fixture/.task', overwrite: true);

    'task rc.confirmation:no config taskd.${pem.key} -- $fixture/.task/${pem.value}'
        .run;
  }

  'task rc.confirmation:no config taskd.server -- localhost:53589'.run;
  'task rc.confirmation:no config taskd.credentials -- $org/$user/$key'.run;

  var contents = File('$fixture/.taskrc')
      .readAsStringSync()
      .replaceAll(r'=.\/', '=fixture\/');
  await File('$fixture/.taskrc').writeAsString(contents);
}
