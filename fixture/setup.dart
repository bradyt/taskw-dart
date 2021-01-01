// ignore_for_file: avoid_print

import 'dart:io';

Future<void> main() async {
  print('running setup script...');
  if (Platform.environment['GITHUB_ACTIONS'] == 'true') {
    print('running ci setup script...');
    await ciSetup();
  } else if (Platform.isMacOS ||
      Platform.environment['WSL_DISTRO_NAME']?.isNotEmpty != null) {
    print('running local setup script...');
    await localSetup();
    // ignore: avoid_slow_async_io
  } else if (Platform.isLinux && await File('/.dockerenv').exists()) {
    print('running docker setup script...');
    await dockerSetup();
  }
  print('done');
}

Future<void> ciSetup() async {
  // toc: https://taskwarrior.org/docs/taskserver/setup.html

  // 3: https://taskwarrior.org/docs/taskserver/configure.html

  for (var pem in [
    'client.cert.pem',
    'client.cert.pem',
    'client.key.pem',
    'server.cert.pem',
    'server.key.pem',
    'server.crl.pem',
    'ca.cert.pem',
  ]) {
    await File('fixture/pki/$pem').copy('/var/taskd/$pem');
  }

  // 3: https://taskwarrior.org/docs/taskserver/control.html

  await Process.run('taskdctl', ['start']);

  // 4: https://taskwarrior.org/docs/taskserver/user.html

  var org = 'Public';
  var user = 'First Last';

  await Process.run('taskd', ['add', 'org', org]);
  var result = await Process.run('taskd', ['add', 'user', org, user]);

  var key = result.stdout.split('\n').first.split(': ').last;
  var credentials = '$org/$user/$key';

  // 4: https://taskwarrior.org/docs/taskserver/taskwarrior.html

  var home = Platform.environment['HOME'];

  await Process.run('cp', ['-r', 'fixture/.task', '$home/']);
  await Process.run('cp', ['fixture/.taskrc.template', '$home/.taskrc']);
  await Process.run(
      'task', ['rc.confirmation:no', 'config', 'confirmation', '--', 'no']);
  await Process.run('task', ['config', 'taskd.credentials', '--', credentials]);

  // 5: https://taskwarrior.org/docs/taskserver/sync.html

  await Process.run('task', ['sync', 'init']);
  await Process.run('task', ['config', 'confirmation', '--', 'yes']);
}

Future<void> localSetup() async {
  ProcessResult result;

  // toc: https://taskwarrior.org/docs/taskserver/setup.html

  // 3: https://taskwarrior.org/docs/taskserver/configure.html

  var taskddata = './var/taskd';

  await Directory(taskddata).create(recursive: true);
  await Process.run('taskd', ['init', '--data', taskddata]);

  for (var pem in [
    'client.cert',
    'client.key',
    'server.cert',
    'server.key',
    'server.crl',
    'ca.cert',
  ]) {
    await File('pki/$pem.pem').copy('$taskddata/$pem.pem');
    await Process.run('taskd',
        ['config', '--force', pem, '$taskddata/$pem.pem', '--data', taskddata]);
  }
  await Process.run('taskd',
      ['config', '--force', 'log', '/dev/stdout', '--data', taskddata]);
  await Process.run('taskd',
      ['config', '--force', 'server', 'localhost:53589', '--data', taskddata]);

  // 3: https://taskwarrior.org/docs/taskserver/control.html

  await Process.run('taskd', ['config', 'debug.tls', '2', '--data', taskddata]);

  // 4: https://taskwarrior.org/docs/taskserver/user.html

  var org = 'Public';
  var user = 'First Last';

  await Process.run('taskd', ['add', 'org', org, '--data', taskddata]);
  result = await Process.run(
      'taskd', ['add', 'user', org, user, '--data', taskddata]);

  var key = result.stdout.split('\n').first.split(': ').last;
  var credentials = '$org/$user/$key';

  // 4: https://taskwarrior.org/docs/taskserver/taskwarrior.html

  await Process.run('cp', ['.taskrc.template', '.taskrc']);

  result = await Process.run(
      'task', ['config', 'taskd.credentials', '--', credentials],
      environment: {'HOME': '.'});
}

Future<void> dockerSetup() async {
  // toc: https://taskwarrior.org/docs/taskserver/setup.html

  // 3: https://taskwarrior.org/docs/taskserver/configure.html

  Directory.current = '/opt/';

  for (var pem in [
    'client.cert.pem',
    'client.cert.pem',
    'client.key.pem',
    'server.cert.pem',
    'server.key.pem',
    'server.crl.pem',
    'ca.cert.pem',
  ]) {
    await File('fixture/pki/$pem').copy('/var/taskd/$pem');
  }

  // 4: https://taskwarrior.org/docs/taskserver/user.html

  var home = Platform.environment['HOME'];

  var org = 'Public';
  var user = 'First Last';

  await Process.run('taskd', ['add', 'org', org]);
  var result = await Process.run('taskd', ['add', 'user', org, user]);

  var key = result.stdout.split('\n').first.split(': ').last;
  var credentials = '$org/$user/$key';

  // 4: https://taskwarrior.org/docs/taskserver/taskwarrior.html

  await Process.run('cp', ['-r', 'fixture/.task', '$home/']);
  await Process.run('cp', ['fixture/.taskrc.template', '$home/.taskrc']);

  await Process.run(
      'task', ['rc.confirmation:no', 'config', 'confirmation', '--', 'no']);
  await Process.run('task', ['config', 'taskd.credentials', '--', credentials]);
  await Process.run('task', ['config', 'confirmation', '--', 'yes']);

  await Process.run('cp', ['$home/.taskrc', 'fixture']);

  await Process.run(
      'task', ['rc.confirmation:no', 'config', 'confirmation', '--', 'no']);

  await Process.run(
      'task', ['taskd.certificate', '--', '~/.task/first_last.cert.pem']);
  await Process.run('task', ['taskd.key', '--', '~/.task/first_last.key.pem']);
  await Process.run('task', ['taskd.ca', '--', '~/.task/ca.cert.pem']);

  await Process.run('task', ['config', 'confirmation', '--', 'yes']);
}
