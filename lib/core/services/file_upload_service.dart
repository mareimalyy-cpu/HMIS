import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../../features/attachments/data/services/supabase_storage_service.dart';


class FileUploadService {

  FileUploadService._();
  static const int maxSizeBytes = 5 * 1024 * 1024; // 5 MB
  static const int maxFiles = 3;
  static const List<String> allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'pdf',
    'xls',
    'xlsx',
    'doc',
    'docx',
  ];
  static final FileUploadService instance = FileUploadService._();

  /// Opens the system file picker filtered to allowed types.
  /// Returns null if the user cancelled.
  Future<List<PlatformFile>?> pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: false,
      withReadStream: false,
    );
    return result?.files;
  }

  /// Returns a locale key (error code) or null if the file is valid.
  String? validate(PlatformFile file, int currentCount) {
    if (currentCount >= maxFiles) return 'max_files_reached';

    final ext = (file.extension ?? '').toLowerCase();
    if (!allowedExtensions.contains(ext)) return 'unsupported_file_type';

    if (file.size > maxSizeBytes) return 'file_too_large';

    return null;
  }

  /// Uploads a file to Supabase and returns the public URL.
  Future<String> upload({
    required String patientId,
    required String fileName,
    required File file,
  }) async {
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    return SupabaseStorageService.instance.uploadAttachment(
      userId: patientId,
      folder: 'appointment-attachments',
      file: file,
      fileName: uniqueName,
    );
  }

  /// Best-effort deletion of an uploaded file via its public URL.
  Future<void> deleteByUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      // URL path: /storage/v1/object/public/{bucket}/{...path}
      final publicIndex = segments.indexOf('public');
      if (publicIndex == -1 || publicIndex + 2 >= segments.length) return;
      final bucket = segments[publicIndex + 1];
      final filePath = segments.sublist(publicIndex + 2).join('/');
      await SupabaseStorageService.instance.deleteFileByPath(
        bucket: bucket,
        path: filePath,
      );
    } catch (_) {}
  }
}
