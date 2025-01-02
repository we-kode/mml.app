import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mml_app/models/record.dart';
import 'package:mml_app/services/api.dart';
import 'package:mml_app/services/messenger.dart';
import 'package:mml_app/services/secure_storage.dart';
import 'package:mml_app/util/xor_encryptor.dart';
import 'package:path_provider/path_provider.dart';

/// Service which handles operations on files on disk.
class FileService {
  /// Instance of the service.
  static final FileService _instance = FileService._();

  /// Returns the singleton instance of the [FileService].
  static FileService getInstance() {
    return _instance;
  }

  /// Returns the actual folder to store the offline records.
  Future<String> get _folder async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/records';
  }

  // Service to show messages.
  final MessengerService _messengerService = MessengerService.getInstance();

  /// Private constructor of the service.
  FileService._();

  /// Creates folder where to store downloaded records.
  Future<void> createFolder() async {
    await Directory(await _folder).create(recursive: true);
  }

  /// Removes all saved files from records folder.
  Future<void> clear() async {
    final files = Directory(await _folder).listSync();
    for (FileSystemEntity entity in files) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }

  /// Removes saved file with [fileName] from disk.
  Future<void> remove(String fileName) async {
    final file = File('${await _folder}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Downloads the [record] from server if not already available on disk.
  ///
  /// [onProgress] shows the progress of downloading.
  Future<void> download(
    Record record, {
    ProgressCallback? onProgress,
    VoidCallback? onError,
  }) async {
    var savePath = '${await _folder}/${record.checksum}';
    final cryptFile = File(savePath);

    if ((await cryptFile.exists()) && (await cryptFile.length()) > 0) {
      return;
    }

    final cryptKey = await SecureStorageService.getInstance().get(
      SecureStorageService.cryptoKey,
    );

    Response<ResponseBody> response =
        await ApiService.getInstance().request<ResponseBody>(
      '/media/stream/${record.recordId}',
      options: Options(
        responseType: ResponseType.stream,
        receiveTimeout: Duration.zero,
      ),
    );

    var size = int.tryParse(
          response.headers["content-length"]?.first ?? "",
        ) ??
        0;
    var downloadedAndEncryptedSize = 0;

    try {
      await (response.data?.stream as Stream<Uint8List>)
          .asyncMap((Uint8List chunk) async {
            final encryptChunk = XorEncryptor.encrypt(
              chunk,
              int.parse(cryptKey!),
            );

            await cryptFile.writeAsBytes(encryptChunk, mode: FileMode.append);

            if (onProgress != null) {
              downloadedAndEncryptedSize += chunk.length;
              onProgress(downloadedAndEncryptedSize, size);
            }

            return encryptChunk;
          })
          .listen((event) {})
          .asFuture();
    } catch (e) {
      _messengerService.showMessage(_messengerService.downloadError);
      cryptFile.delete();
      onError?.call();
    }
  }

  /// Loads file with [record] as decrypted byte chunked stream.
  Future<File> getFile(Record record) async {
    final file = File('${await _folder}/${record.checksum}');
    if (!(await file.exists())) {
      await download(record, onError: () {
        _messengerService.showMessage(_messengerService.fileNotFound);
        throw Exception("File not found!");
      });
    }

    return file;
  }
}
