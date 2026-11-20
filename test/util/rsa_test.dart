import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mml_app/util/rsa.dart';
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

// Throwaway test key generated with `openssl genrsa -traditional 2048`.
const _privateKey = '''
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAyBcpHeCKEjXveryEUDUh3C/gysXMEomVT57nz0qDD1L7nSQ7
ku2ITx8xMDgEs64zufgp43L+q48Mu7q0lfItPC85O7sv6Q1IEB3v9l42nUPiE8Tn
LVFzwJnIvPC7zDH3hLThYcgCSYPHhdqoZG6DZU/OEuj8yH18l4kV2zNVbxzliWo3
zjeVnzkeqsFzmidcjfARIWh+6Fp/i1HKMs1xJjWU8YpmavE5GxbfYzZSY71kIwgB
ci1HMA00VsFmLR4H6SZzwzgvC9m6M0elEPEGTdBMB33S3lovbvwi0XZRoVDqc4q9
cdjHwBejCgGqYV5QVPx/PHOqDMmsuBalnHPE7wIDAQABAoIBAF8+6yMeOgtOIlel
+kPl7t7N6a8MdcaTOICEr2r02KtIQJ6+Wx9nM54aRoNh/xb7AwNw9pufJ0xKFXEd
gI3qEI9YGWHuCnHhER8e6RW5Jj05TZpEfhkL71JMwgnyfCrI1D6XDbxKhZAyCx2U
Btl7488rrHhC8OWNGmxV5JIJ/w6a9Wi6a/6xkpGje+rm0Cyc2GLmxmeZJWX8PYdx
+AWlvbnLgR3OGWnwB4P0cSy7I6beCPP9ZQhOhu4ynnpzZVRFBJdrOW6VwMXjJKwb
5yQENV2gqBy759xfolYgQ1FgEToN0r52NSuVuDgh43JRtBegpAxf2KDaRqiWFW7C
lYoamoECgYEA/Zh13JVxAh15xXUtsqFvhyg+waOYoydLuEKhEFpej42K6QamMbou
SjXo/79+KoH0X5pueYKrcRITdFE13saaOx7gRg1OeJ0enJrA+lI+rNh9xzUMJYZQ
/VxQhMb79/jzOhgd8OkMdn7hWD9NRQckggPclQeR+iZtoSyYFkEkBYECgYEAyfzU
fpjcGTfzNMVxl2VugilIT8WA8Nz1CCfEhwU0AxfYo3JE2cu+UEW+hULDJyGNiq+V
dN3+ts8l2yzGa+JbkRy2r0khzVjGvS5NXstjeU+415n5VrfywSKSqLt2e/2kj+VQ
09saAXO+eZjwF27sdErU3MFWTJAJw0zVNZS6Ym8CgYAd9C0vweMYSd0BSsb8C399
6m4HN0inNNQHzq7xnIsAz8oxnhxxUTl4gIel9bt0T+dKh5Y2+g1ADM+JdLI1PyYm
h44cGCRFsOFVxB25M4+9oNCyf/yQTh4w3v+Pv2UxtBEesoyO0Sgssu3xG4EH/0D7
rnMWk09VycY3PGo2brlPgQKBgQDGSHMVP9u4yeru3/Btjb4Y+ouo+5pjWJUWB2vu
m9X+P1eEw/UA1PijdoPb77kB3fdDsLAIBLE6JknkSaUTXSdEYaqYkjMjkUWvixea
uhCRkwhCZj2VuogMvnK4PybF+y2jsJpTDuANkuDmH5N5fYOTea5Sc1zTVgaveOpI
ahM58wKBgHOCPXwoWRVV2Y6jWmfJYtfSzIoIUYAnOK67JLdgsOfLybfxXlVpU0s+
YKA9daW+GC5cK+W67myClURwbez8bLc0mabG0tOmM6CS2I0Fr9Mqk84D4NFf1nMj
Jwy2y+acCqIH3Ided3qN7XPR+F8O/9EQyhMjE2bc95pIEdkIgELU
-----END RSA PRIVATE KEY-----
''';

// Created with `openssl dgst -sha512 -sign` over [_message] and base64.
const _signature =
    'OWmuuVNSvOd/rlnHh++yCTuI7doK97Jlhs/fc+NryQ6pbtgB3WJD3sYrAJxtZybXL4qrRpfB3WtfjPP77qJIAu7EgFeBxWzxns/zJteTooM6jMr3mPCCTr8OOVTPb2vLrXtR5u2p8WmUSvEVEHbuPf148e+fknXt3ics80a6TnC5GYleGwLyddPaHC4X2to1PUQy1sP1uR5OkAbEkIFgzUhINqq/peHYRgKDoGUnViesh0Z2aHQfPW4cq+CmGIvh3pgiUdiPC0pzDKIxqTzjNXL+ZWLquhBgrc2axvuUp2X/gvNscKM5X1YsPfm2zJuqjqXQHWiCmVCnKjGczrgOFQ==';

const _message =
    '{"grant_type":"client_credentials","client_id":"id","client_secret":"secret"}';

List<BigInt> _integers(String pem) {
  final body = pem
      .split('\n')
      .where((line) => line.isNotEmpty && !line.startsWith('-----'))
      .join();
  final sequence = ASN1Parser(base64Decode(body)).nextObject() as ASN1Sequence;
  return [for (final e in sequence.elements!) (e as ASN1Integer).integer!];
}

void main() {
  test('signs like openssl with an existing PKCS#1 key', () async {
    expect(await Rsa.sign(_message, _privateKey), _signature);
  });

  test('generates PKCS#1 keys, whose signatures are valid', () async {
    final keyPair = await Rsa.generate(2048);
    expect(keyPair.privateKey, startsWith('-----BEGIN RSA PRIVATE KEY-----\n'));
    expect(keyPair.publicKey, startsWith('-----BEGIN RSA PUBLIC KEY-----\n'));

    final public = _integers(keyPair.publicKey);
    final private = _integers(keyPair.privateKey);
    expect(public, [private[1], private[2]]);
    expect(public[1], BigInt.from(65537));

    final signature = await Rsa.sign(_message, keyPair.privateKey);
    final verifier = RSASigner(SHA512Digest(), '0609608648016503040203')
      ..init(
        false,
        PublicKeyParameter<RSAPublicKey>(RSAPublicKey(public[0], public[1])),
      );
    expect(
      verifier.verifySignature(
        Uint8List.fromList(utf8.encode(_message)),
        RSASignature(base64Decode(signature)),
      ),
      isTrue,
    );
  });

  test('fails for an unreadable key', () {
    expect(Rsa.sign(_message, ''), throwsA(anything));
  });
}
