import 'dart:io';

class PemFilePaths {
  const PemFilePaths({
    this.ca,
    this.certificate,
    this.key,
  });

  factory PemFilePaths.fromTaskrc(Map taskrc) {
    return PemFilePaths(
      ca: taskrc['taskd.ca'],
      certificate: taskrc['taskd.certificate'],
      key: taskrc['taskd.key'],
    );
  }

  final String? ca;
  final String? certificate;
  final String? key;

  SecurityContext securityContext() {
    var context = (ca != null && File(ca!).existsSync())
        ? (SecurityContext()..setTrustedCertificates(ca!))
        : SecurityContext.defaultContext;
    if (certificate != null) {
      context.useCertificateChain(certificate!);
    }
    if (key != null) {
      context.usePrivateKey(key!);
    }
    return context;
  }
}
