// Conditional export: use web implementation when building for web, otherwise stub.
export 'cloudinary_uploader_stub.dart'
    if (dart.library.html) 'cloudinary_uploader_web.dart';
