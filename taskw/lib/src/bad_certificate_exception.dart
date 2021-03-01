import 'dart:io';

class BadCertificateException implements Exception {
  BadCertificateException({
    required this.profile,
    required this.certificate,
  });

  Directory profile;
  X509Certificate certificate;
}
