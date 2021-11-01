import 'dart:io';

import 'package:taskc/storage.dart';
import 'package:taskc/taskc.dart';
import 'package:taskc/taskc_impl.dart';
import 'package:taskc/taskrc.dart';

class TaskdClient {
  TaskdClient({
    this.taskrc,
    this.client,
    this.pemFilePaths,
    this.throwOnBadCertificate,
  });

  final Taskrc? taskrc;
  final String? client;
  final PemFilePaths? pemFilePaths;
  final void Function(X509Certificate)? throwOnBadCertificate;

  PemFilePaths _pemFilePaths() {
    return pemFilePaths ??
        PemFilePaths.fromTaskrc(
          taskrc?.pemFilePaths.map ?? {},
        );
  }

  bool _onBadCertificate(X509Certificate serverCert) {
    if (_pemFilePaths().savedServerCertificateMatches(serverCert)) {
      return true;
    } else if (throwOnBadCertificate != null) {
      throwOnBadCertificate!(serverCert);
      return true;
    }
    return false;
  }

  Future<Response> request({
    required String type,
    String? payload,
  }) async {
    if (taskrc?.server == null) {
      throw TaskserverConfigurationException(
        'Server cannot be null.',
      );
    }

    var socket = await Socket.connect(
      taskrc!.server!.address,
      taskrc!.server!.port,
    );

    var secureSocket = await SecureSocket.secure(
      socket,
      context: _pemFilePaths().securityContext(),
      onBadCertificate: _onBadCertificate,
    );

    var _message = message(
      type: type,
      client: client,
      credentials: taskrc?.credentials,
      payload: payload,
    );

    var responseBytes = await send(
      socket: secureSocket,
      bytes: Codec.encode(_message),
    );

    await secureSocket.close();
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
