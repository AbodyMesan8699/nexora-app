import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// All Storage access goes through here. Object paths are prefixed with the
/// uploader's uid — matching the storage policies (path prefix = auth.uid()).
class StorageService {
  static SupabaseClient get _c => Supabase.instance.client;

  static String get _uid => _c.auth.currentUser!.id;

  static Future<String> upload({
    required File file,
    required String bucket,
    String? ext,
  }) async {
    final e = ext ?? file.path.split('.').last.toLowerCase();
    final path = '$_uid/${DateTime.now().millisecondsSinceEpoch}.$e';
    await _c.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(
            upsert: false,
            cacheControl: '3600',
            contentType: _contentType(e),
          ),
        );
    return _c.storage.from(bucket).getPublicUrl(path);
  }

  static Future<String> uploadBytes({
    required Uint8List bytes,
    required String bucket,
    required String ext,
  }) async {
    final path = '$_uid/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _c.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: false,
            cacheControl: '3600',
            contentType: _contentType(ext),
          ),
        );
    return _c.storage.from(bucket).getPublicUrl(path);
  }

  static String _contentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'webm':
        return 'video/webm';
      case 'mov':
        return 'video/quicktime';
      case 'mp4':
      default:
        return 'video/mp4';
    }
  }

  static const buckets = [
    'profile-images',
    'cover-images',
    'post-media',
    'message-media',
    'story-media',
  ];
}
