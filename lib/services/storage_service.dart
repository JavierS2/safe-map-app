import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    try {
      await ref.putFile(file).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('StorageService: putFile timeout');
      });
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload raw bytes (useful for web where dart:io File is not available)
  Future<String> uploadImageBytes(Uint8List bytes, String path, {String? contentType}) async {
    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: contentType ?? 'image/png');
    try {
      await ref.putData(bytes, metadata).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('StorageService: putData timeout');
      });
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      rethrow;
    }
  }
}
