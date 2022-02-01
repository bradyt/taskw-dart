import 'dart:convert';

import 'package:test/test.dart';

// https://github.com/freecinc/freecinc-web/blob/master/models/forge.rb#L61-L72
// https://github.com/freecinc/freecinc-web/blob/master/spec/models/forge_spec.rb#L53-L64

// https://mirakel.azapps.de/taskwarrior.html#config-file

var _mirakelExample = '''
username: foo
org: bar
user key: baz
server: qux
client.cert:
quux
corge
grault
Client.key:
garply
waldo
fred
ca.cert:
plugh
xyzzy
thud
''';

var _mirakelRegExp = ((x) => RegExp(
      '^($x)',
      multiLine: true,
    ))({
  'username: ',
  'org: ',
  'user key: ',
  'server: ',
  'client.cert:\n',
  'Client.key:\n',
  'ca.cert:\n',
}.join('|'));

class Mirakel {
  const Mirakel({
    required this.username,
    required this.org,
    required this.userKey,
    required this.server,
    required this.clientCert,
    required this.clientKey,
    required this.caCert,
  });

  factory Mirakel.fromString(String mirakel) {
    var split =
        mirakel.split(_mirakelRegExp).map((match) => match.trim()).toList();
    return Mirakel(
      username: split[1],
      org: split[2],
      userKey: split[3],
      server: split[4],
      clientCert: split[5],
      clientKey: split[6],
      caCert: split[7],
    );
  }

  final String username;
  final String org;
  final String userKey;
  final String server;
  final String clientCert;
  final String clientKey;
  final String caCert;

  Map toMap() => {
        'username': username,
        'org': org,
        'userKey': userKey,
        'server': server,
        'clientCert': clientCert,
        'clientKey': clientKey,
        'caCert': caCert,
      };

  @override
  String toString() => const JsonEncoder.withIndent(' ').convert(toMap());
}

void main() {
  test('test mirakel', () {
    expect(
      Mirakel.fromString(_mirakelExample).toMap(),
      {
        'username': 'foo',
        'org': 'bar',
        'userKey': 'baz',
        'server': 'qux',
        'clientCert': 'quux\ncorge\ngrault',
        'clientKey': 'garply\nwaldo\nfred',
        'caCert': 'plugh\nxyzzy\nthud',
      },
    );
  });
}
