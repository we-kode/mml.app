import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// An extension to format base64 string to file and return the file.
extension StringExtended on String {
  /// Returns file from base64 string.
  Future<File> toFile() async {
    final byteData = base64.decode(this);

    final file = File('${(await getTemporaryDirectory()).path}/apc.jpg');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}
