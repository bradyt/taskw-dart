import 'dart:io';

class Config {
  Config({this.conf});

  factory Config.fromTaskrc(String taskrc, {bool relative = false}) {
    var file = File(taskrc);
    var xs = file.readAsStringSync().split('\n');
    var conf = {
      for (var x in xs
          .where((x) => x.contains('=') && x[0] != '#')
          .map((x) => x.replaceAll('\\/', '/'))
          .map((x) => x.split('=')))
        x[0]: relative ? x[1].replaceFirst(RegExp(r'^/'), '') : x[1],
    };
    return Config(conf: conf);
  }

  final Map conf;

  ConnectionData get connectionData => ConnectionData(
        address: conf['taskd.server'].split(':').first,
        port: int.parse(conf['taskd.server'].split(':').last),
        certificate: conf['taskd.certificate'],
        key: conf['taskd.key'],
        ca: conf['taskd.ca'],
      );

  AuthData get authData => AuthData(
        org: conf['taskd.credentials'].split('/').first,
        user: conf['taskd.credentials'].split('/')[1],
        key: conf['taskd.credentials'].split('/').last,
      );
}

class AuthData {
  AuthData({
    this.org,
    this.user,
    this.key,
  });

  final String org;
  final String user;
  final String key;
}

class ConnectionData {
  ConnectionData({
    this.address,
    this.port,
    this.certificate,
    this.key,
    this.ca,
  });

  final String address;
  final int port;
  final String certificate;
  final String key;
  final String ca;
}
