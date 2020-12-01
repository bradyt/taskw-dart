import 'dart:io';

Future<void> main() async {
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
