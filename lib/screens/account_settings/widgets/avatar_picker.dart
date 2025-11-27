import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';

/// AvatarPicker: Stateful widget that shows avatar image and a camera badge.
/// Handles its own image picking (camera / gallery) and displays the picked image.
class AvatarPicker extends StatefulWidget {
  final double size;
  final ValueChanged<XFile?>? onImageChanged;
  final String? imageUrl;

  const AvatarPicker({Key? key, required this.size, this.onImageChanged, this.imageUrl}) : super(key: key);

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  XFile? _picked;
  Uint8List? _pickedBytes;

  Future<void> _showImageSourceActionSheet() async {
    final pickedSource = await showModalBottomSheet<ImageSource>(
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
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );

    if (pickedSource != null) {
      await _pickImage(pickedSource);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: source, maxWidth: 1200, imageQuality: 85);
      if (!mounted) return;
      if (file != null) {
        // Validate file size: maximum 1 MB
        if (kIsWeb) {
          final bytes = await file.readAsBytes();
          if (bytes.length > 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La imagen excede el tamaño máximo de 1 MB')));
            return;
          }
          setState(() {
            _picked = file;
            _pickedBytes = bytes;
          });
          widget.onImageChanged?.call(file);
        } else {
          final f = File(file.path);
          final len = await f.length();
          if (len > 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La imagen excede el tamaño máximo de 1 MB')));
            return;
          }
          setState(() {
            _picked = file;
            _pickedBytes = null;
          });
          widget.onImageChanged?.call(file);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo obtener la imagen')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return GestureDetector(
      onTap: _showImageSourceActionSheet,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                image: _picked != null
                  ? (kIsWeb
                    ? DecorationImage(fit: BoxFit.cover, image: MemoryImage(_pickedBytes!))
                    : DecorationImage(fit: BoxFit.cover, image: FileImage(File(_picked!.path))))
                  : (widget.imageUrl != null
                    ? DecorationImage(fit: BoxFit.cover, image: NetworkImage(widget.imageUrl!))
                    : const DecorationImage(fit: BoxFit.cover, image: AssetImage('assets/images/avatar.png'))),
              ),
            ),

            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
