// Stub implementation for non-web platforms.
import 'dart:typed_data';

Future<String> uploadBytesToCloudinary(Uint8List bytes, String fileName, {String folder = ''}) async {
  throw UnimplementedError('Cloudinary web uploader is only available on web.');
}
