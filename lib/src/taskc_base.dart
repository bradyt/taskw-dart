import 'dart:io';
import 'dart:typed_data';

class TaskdConnection {
  TaskdConnection({
    this.clientCert,
    this.clientKey,
    this.cacertFile,
    this.server,
    this.port,
    this.group,
    this.username,
    this.uuid,
  });

  final String clientCert;
  final String clientKey;
  final String cacertFile;
  final String server;
  final int port;
  final String group;
  final String username;
  final String uuid;

  factory TaskdConnection.fromTaskrc(String taskrc) {
    var file = File(taskrc);
    var xs = file.readAsStringSync().split('\n');
    var conf = {
      for (var item in xs
          .where((x) => x.contains('=') && x[0] != '#')
          .map((x) => x.replaceAll('\\/', '/'))
          .map((x) => x.split('=')))
        item[0]: item[1],
    };

    return TaskdConnection(
      clientCert: conf['taskd.certificate'],
      clientKey: conf['taskd.key'],
      cacertFile: conf['taskd.ca'],
      server: conf['taskd.server'].split(':').first,
      port: int.parse(conf['taskd.server'].split(':').last),
      group: conf['taskd.credentials'].split('/').first,
      username: conf['taskd.credentials'].split('/')[1],
      uuid: conf['taskd.credentials'].split('/').last,
    );
  }

  Future<Uint8List> sendMessageAsBytes(Uint8List message) async {
    var context = SecurityContext()
      ..useCertificateChain(clientCert)
      ..usePrivateKey(clientKey)
      ..setTrustedCertificates(cacertFile);

    var socket = await SecureSocket.connect(
      server,
      port,
      context: context,
      onBadCertificate: (_) => true,
    );

    socket.add(message);

    return socket.first;
  }
}
