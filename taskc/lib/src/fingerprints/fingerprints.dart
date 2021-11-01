import 'package:crypto/crypto.dart';
import 'package:pem/pem.dart';

Iterable<Digest> fingerprints(dynamic foo, dynamic bar) =>
    decodePemBlocks(foo, bar).map((block) => sha1.convert(block));
