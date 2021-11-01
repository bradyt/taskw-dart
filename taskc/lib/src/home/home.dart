import 'dart:io';

import 'package:taskc/home_impl.dart';
import 'package:taskc/storage.dart';
import 'package:taskc/taskrc.dart' as rc;

class Home {
  const Home({
    required this.home,
    this.pemFilePaths,
    this.onBadCertificate,
  });

  final Directory home;
  final rc.PemFilePaths? pemFilePaths;
  final bool Function(X509Certificate)? onBadCertificate;

  Data get _data => Data(home);
  File get _taskrc => File('${home.path}/.taskrc');

  TaskdClient _taskdClient(client) {
    return TaskdClient(
      taskrc: (!_taskrc.existsSync())
          ? null
          : rc.Taskrc.fromString(_taskrc.readAsStringSync()),
      client: client,
      pemFilePaths: pemFilePaths,
      throwOnBadCertificate: (badCertificate) => throw BadCertificateException(
        home: home,
        certificate: badCertificate,
      ),
    );
  }

  Future<Map> statistics(String client) {
    return _taskdClient(client).statistics();
  }

  Future<Map> synchronize(String client) async {
    var _payload = _data.payload();
    var response = await _taskdClient(client).synchronize(
      _payload,
    );
    _data.mergeSynchronizeResponse(response.payload);
    return response.header;
  }
}
