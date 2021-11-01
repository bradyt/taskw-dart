class Server {
  const Server({
    required this.address,
    required this.port,
  });

  factory Server.fromString(String server) {
    var split = server.split(':');
    var address = split[0];
    var port = int.parse(split[1]);

    return Server(
      address: address,
      port: port,
    );
  }

  final dynamic address;
  final int port;
}
