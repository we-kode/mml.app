import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Service which handles operations on files on disk.
class FileService {
  /// Instance of the service.
  static final FileService _instance = FileService._();

  /// Returns the singleton instance of the [FileService].
  static FileService getInstance() {
    return _instance;
  }

  Future<String> get _folder async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/records';
  }

  /// Private constructor of the service.
  FileService._();

  /// Creates folder where to store downloaded records.
  Future createFolder() async {
    await Directory(await _folder).create(recursive: true);
  }

  /// Removes all saved files from records folder.
  Future clear() async {
    final files = Directory(await _folder).listSync();
    for (FileSystemEntity entity in files) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }

  /// Removes saved file with [fileName] from disk.
  Future remove(String fileName) async {
    final file = File('${await _folder}/$fileName.mml');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Downloads the [record] from server if not already available on disk.
  ///
  /// [onProgress] shows the progress of downloading.
  Future download(Record record, {ProgressCallback? onProgress}) async {
    var savePath = '${await _folder}/${record.file}';
    final file = File(savePath);
    final cryptFile = File('$savePath.mml');
    if (await cryptFile.exists()) {
      return;
    }
    await ApiService.getInstance().download(
      '/media/record/download/${record.recordId}',
      savePath,
      onReceiveProgress: onProgress,
    );

    // encrypt file in chunks.
    final crypt = await SecureStorageService.getInstance()
        .get(SecureStorageService.cryptoKey);
    final key = Key.fromBase64(crypt!);
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(key));

    var readStream = file.openRead();
    readStream.listen((chunk) {
      final encryptChunk = encrypter.encryptBytes(chunk, iv: iv);
      cryptFile.writeAsBytesSync(encryptChunk.bytes, mode: FileMode.append);
    });

    file.delete();
  }

  /// Loads file with [fileName] as decrypted byte chunked stream.
  Future getFile(String fileName) async {
    // TODO decrypt file and return byteStream do not load whole file into memory. cause of memeory exception on large files.
    // encrypted files have the .mml extension
  }
}
