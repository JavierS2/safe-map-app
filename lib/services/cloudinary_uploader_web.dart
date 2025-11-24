// Web implementation: uses dart:html to POST FormData to Cloudinary unsigned upload.
// This file is only used on web builds via conditional export.
import 'dart:typed_data';
import 'dart:convert';
import 'dart:html' as html;

const _cloudName = 'dzi4xj2eb';
const _uploadPreset = 'safemap_unsigned';

Future<String> uploadBytesToCloudinary(Uint8List bytes, String fileName, {String folder = ''}) async {
  final url = 'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  try {
    final blob = html.Blob([bytes]);
    final fd = html.FormData();
    fd.appendBlob('file', blob, fileName);
    fd.append('upload_preset', _uploadPreset);
    if (folder.isNotEmpty) fd.append('folder', folder);

    final request = await html.HttpRequest.request(
      url,
      method: 'POST',
      sendData: fd,
      requestHeaders: {},
    );

    if (request.status == 200 || request.status == 201) {
      final resp = json.decode(request.responseText ?? '{}');
      final secureUrl = resp['secure_url'] as String?;
      if (secureUrl == null) throw Exception('Cloudinary response missing secure_url');
      return secureUrl;
    } else {
      throw Exception('Cloudinary upload failed: HTTP ${request.status}');
    }
  } catch (e) {
    rethrow;
  }
}
