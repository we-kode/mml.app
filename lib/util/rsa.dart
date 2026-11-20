import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

/// RSA key pair with both keys encoded as PKCS#1 PEM.
typedef RsaPemKeyPair = ({String privateKey, String publicKey});

/// Generates RSA keys and signatures in the PKCS#1 formats verified by the
/// identity service.
class Rsa {
  Rsa._();

  /// Generates a key pair with a modulus of [bits] in a background isolate.
  static Future<RsaPemKeyPair> generate([int bits = 4096]) {
    return Isolate.run(() => _generate(bits));
  }

  /// Signs the [message] with the PKCS#1 PEM encoded [privateKey] using
  /// RSASSA-PKCS1-v1_5 with SHA-512 in a background isolate and returns the
  /// base64 encoded signature.
  static Future<String> sign(String message, String privateKey) {
    return Isolate.run(() => _sign(message, privateKey));
  }

  static RsaPemKeyPair _generate(int bits) {
    final random = Random.secure();
    final secureRandom = FortunaRandom()
      ..seed(
        KeyParameter(
          Uint8List.fromList(List.generate(32, (_) => random.nextInt(256))),
        ),
      );
    final generator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.from(65537), bits, 64),
          secureRandom,
        ),
      );
    final key = generator.generateKeyPair().privateKey;
    final n = key.modulus!;
    final e = key.publicExponent!;
    final d = key.privateExponent!;
    final p = key.p!;
    final q = key.q!;

    return (
      privateKey: _toPem('RSA PRIVATE KEY', [
        BigInt.zero,
        n,
        e,
        d,
        p,
        q,
        d % (p - BigInt.one),
        d % (q - BigInt.one),
        q.modInverse(p),
      ]),
      publicKey: _toPem('RSA PUBLIC KEY', [n, e]),
    );
  }

  static String _sign(String message, String privateKey) {
    final values = _fromPem(privateKey);
    final signer = RSASigner(SHA512Digest(), '0609608648016503040203')
      ..init(
        true,
        PrivateKeyParameter<RSAPrivateKey>(
          RSAPrivateKey(values[1], values[3], values[4], values[5]),
        ),
      );

    return base64Encode(
      signer.generateSignature(Uint8List.fromList(utf8.encode(message))).bytes,
    );
  }

  static String _toPem(String label, List<BigInt> values) {
    final body = base64Encode(
      ASN1Sequence(elements: [for (final v in values) ASN1Integer(v)]).encode(),
    );
    final lines = [
      for (var i = 0; i < body.length; i += 64)
        body.substring(i, min(i + 64, body.length)),
    ];

    return '-----BEGIN $label-----\n${lines.join('\n')}\n-----END $label-----\n';
  }

  static List<BigInt> _fromPem(String pem) {
    final body = pem
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty && !line.startsWith('-----'))
        .join();
    final sequence =
        ASN1Parser(base64Decode(body)).nextObject() as ASN1Sequence;

    return [for (final e in sequence.elements!) (e as ASN1Integer).integer!];
  }
}
