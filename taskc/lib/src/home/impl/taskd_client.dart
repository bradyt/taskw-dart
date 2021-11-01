import 'dart:io';

import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';
import 'package:taskc/taskrc.dart';

class TaskdClient {
  TaskdClient({
    required this.taskrc,
    this.client,
    this.pemFilePaths,
    this.throwOnBadCertificate,
  });

  final Taskrc taskrc;
  final String? client;
  final PemFilePaths? pemFilePaths;
  final void Function(X509Certificate)? throwOnBadCertificate;

  PemFilePaths _pemFilePaths() {
    return pemFilePaths ??
        PemFilePaths.fromTaskrc(
          taskrc.pemFilePaths.map,
        );
  }

  bool _onBadCertificate(X509Certificate serverCert) {
    if (_pemFilePaths().savedServerCertificateMatches(serverCert)) {
      return true;
    } else if (throwOnBadCertificate != null) {
      throwOnBadCertificate!(serverCert);
    }
    return false;
  }

  Future<Response> request({
    required String type,
    String? payload,
  }) async {
    var socket = await getSocket(
      server: taskrc.server,
      context: _pemFilePaths().securityContext(),
      onBadCertificate: _onBadCertificate,
    );

    var _message = message(
      type: type,
      client: client,
      credentials: taskrc.credentials,
      payload: payload,
    );

    var responseBytes = await send(
      socket: socket,
      bytes: Codec.encode(_message),
    );

    await socket.close();

    if (responseBytes.isEmpty) {
      throw EmptyResponseException();
    }

    var response = Response.fromString(Codec.decode(responseBytes));

    if (![
      '200',
      '201',
      '202',
    ].contains(response.header['code'])) {
      throw TaskserverResponseException(response.header);
    }

    return response;
  }

  Future<Map> statistics() {
    return request(
      type: 'statistics',
    ).then((response) => response.header);
  }

  Future<Response> synchronize(String payload) {
    return request(
      type: 'sync',
      payload: payload,
    );
  }
}
