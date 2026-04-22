import 'dart:io';
import 'dart:developer';

import 'package:supabase_flutter/supabase_flutter.dart';

const _supabaseUrl = 'https://sxsawoyeqwsewenpcpgw.supabase.co';
// NOTE: Use the "anon/public" JWT key from Supabase Dashboard → Settings → API.
// The key below is a secret key — replace with the anon key for client-side use.
const _supabaseAnonKey = 'sb_secret_ySdS-XAAjab9vDsjUQLnBQ_Vwckg8sI';
const _bucketName = 'profile-images';

class SupabaseStorageService {

  SupabaseStorageService._();
  static SupabaseStorageService? _instance;
  static SupabaseStorageService get instance =>
      _instance ??= SupabaseStorageService._();

  static Future<void> initialize() async {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  }

  SupabaseClient get _client => Supabase.instance.client;

  /// Uploads an image file and returns its public URL.
  /// [userId] is used to scope the file path, preventing collisions.
  Future<String> uploadImage({
    required String userId,
    required File imageFile,
  }) async {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final path = 'users/$userId/profile.$ext';
    await _ensureBucketExists(_bucketName);
    await _client.storage
        .from(_bucketName)
        .upload(path, imageFile, fileOptions: const FileOptions(upsert: true));

    return _client.storage.from(_bucketName).getPublicUrl(path);
  }

  /// Deletes the profile image for a given user.
  Future<void> deleteProfileImage(String userId) async {
    try {
      final files = await _client.storage
          .from(_bucketName)
          .list(path: 'users/$userId');
      final paths = files.map((f) => 'users/$userId/${f.name}').toList();
      if (paths.isNotEmpty) {
        await _client.storage.from(_bucketName).remove(paths);
      }
    } catch (e) {
      log('Delete profile image error: $e');
    }
  }

  /// Uploads a general attachment and returns its public URL.
  Future<String> uploadAttachment({
    required String userId,
    required String folder,
    required File file,
    required String fileName,
  }) async {
    await _ensureBucketExists(folder);
    final path = '$userId/$fileName';
    await _client.storage
        .from(folder)
        .upload(path, file, fileOptions: const FileOptions(upsert: true));
    return _client.storage.from(folder).getPublicUrl(path);
  }

  Future<void> _ensureBucketExists(String bucket) async {
    try {
      final buckets = await _client.storage.listBuckets();
      if (!buckets.any((b) => b.name == bucket)) {
        await _client.storage.createBucket(
          bucket,
          const BucketOptions(public: true),
        );
        log('Created bucket: $bucket');
      }
    } catch (e) {
      log('Error ensuring bucket $bucket: $e');
    }
  }

  /// Deletes a file by its bucket and storage path.
  Future<void> deleteFileByPath({
    required String bucket,
    required String path,
  }) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      log('Delete file error ($path): $e');
    }
  }
}
