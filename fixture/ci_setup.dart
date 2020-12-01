// ignore_for_file: avoid_print
import 'dart:io';

Future<void> main() async {
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
