import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  // Pon aquí tu cloud name y upload preset (unsigned)
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dzi4xj2eb',      
    'safemap_unsigned',   
    cache: false,
  );

  Future<String> uploadFile({
    required File file,
    required bool isVideo,
    String? folder,
  }) async {
    final resourceType =
        isVideo ? CloudinaryResourceType.Video : CloudinaryResourceType.Image;

    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: resourceType,
          folder: folder,
        ),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      throw Exception('Cloudinary error: ${e.message}');
    } catch (e) {
      throw Exception('Error al subir a Cloudinary: $e');
    }
  }
}
