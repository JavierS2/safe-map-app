import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_colors.dart';
import '../../../services/cloudinary_service.dart';

class EvidenceUploadBox extends StatefulWidget {
  final void Function(List<String> urls) onEvidenceChanged;

  const EvidenceUploadBox({
    super.key,
    required this.onEvidenceChanged,
  });

  @override
  State<EvidenceUploadBox> createState() => _EvidenceUploadBoxState();
}

class _EvidenceUploadBoxState extends State<EvidenceUploadBox> {
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  bool _uploading = false;
  final List<String> _evidenceUrls = [];
  static const int _maxBytes = 5 * 1024 * 1024; // 5 MB

  Future<void> _pickImage() async {
    // Let the user choose camera or gallery
    final ImageSource? src = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir desde la galería'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.of(ctx).pop(null),
            ),
          ],
        ),
      ),
    );
    if (src == null) return;

    final XFile? picked = await _picker.pickImage(
      source: src,
      imageQuality: 80,
    );
    if (picked == null) return;

    // Validate size before uploading
    try {
      final bytes = await picked.length();
      if (bytes > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El archivo excede el tamaño máximo de 5 MB')),
          );
        }
        return;
      }
    } catch (_) {
      // If we can't get length, fall back to file length check
      final file = File(picked.path);
      if (file.existsSync() && file.lengthSync() > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El archivo excede el tamaño máximo de 5 MB')),
          );
        }
        return;
      }
    }

    await _uploadFile(File(picked.path), isVideo: false);
  }

  Future<void> _pickVideo() async {
    final ImageSource? src = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Grabar video'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Elegir desde la galería'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancelar'),
              onTap: () => Navigator.of(ctx).pop(null),
            ),
          ],
        ),
      ),
    );
    if (src == null) return;

    final XFile? picked = await _picker.pickVideo(
      source: src,
      maxDuration: const Duration(seconds: 30),
    );
    if (picked == null) return;

    // Validate size before uploading
    try {
      final bytes = await picked.length();
      if (bytes > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El archivo excede el tamaño máximo de 5 MB')),
          );
        }
        return;
      }
    } catch (_) {
      final file = File(picked.path);
      if (file.existsSync() && file.lengthSync() > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('El archivo excede el tamaño máximo de 5 MB')),
          );
        }
        return;
      }
    }

    await _uploadFile(File(picked.path), isVideo: true);
  }

  Future<void> _uploadFile(File file, {required bool isVideo}) async {
    try {
      setState(() => _uploading = true);

      final url = await _cloudinaryService.uploadFile(
        file: file,
        isVideo: isVideo,
        folder: 'incidents', // si quieres, luego usas el id del reporte
      );

      setState(() {
        _evidenceUrls.add(url);
      });

      widget.onEvidenceChanged(List<String>.unmodifiable(_evidenceUrls));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evidencia subida correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir evidencia: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidencias',
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.softBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '.JPG, .PNG, .MP4 - Tamaño Máx 5MB',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_uploading) const LinearProgressIndicator(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _uploading ? null : _pickImage,
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text(
                        'Foto',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _uploading ? null : _pickVideo,
                      icon: const Icon(Icons.videocam_outlined, size: 18),
                      label: const Text(
                        'Video',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_evidenceUrls.isNotEmpty)
                Text(
                  'Evidencias añadidas: ${_evidenceUrls.length}',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
