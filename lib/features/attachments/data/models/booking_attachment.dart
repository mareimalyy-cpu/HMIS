import 'dart:io';

class BookingAttachment {

  const BookingAttachment({
    required this.name,
    required this.sizeBytes,
    required this.localPath,
    this.url,
    this.isUploading = false,
    this.uploadError,
  });
  final String name;
  final int sizeBytes;
  final String localPath;
  final String? url;
  final bool isUploading;
  final String? uploadError;

  String get extension =>
      name.contains('.') ? name.split('.').last.toLowerCase() : '';
  bool get isImage => ['jpg', 'jpeg', 'png'].contains(extension);
  bool get isPdf => extension == 'pdf';
  bool get isExcel => ['xls', 'xlsx'].contains(extension);
  bool get isWord => ['doc', 'docx'].contains(extension);
  bool get isUploaded => url != null && !isUploading;

  File get file => File(localPath);

  String get displaySize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  BookingAttachment copyWith({
    String? name,
    int? sizeBytes,
    String? localPath,
    String? url,
    bool? isUploading,
    String? uploadError,
    bool clearError = false,
    bool clearUrl = false,
  }) {
    return BookingAttachment(
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      localPath: localPath ?? this.localPath,
      url: clearUrl ? null : (url ?? this.url),
      isUploading: isUploading ?? this.isUploading,
      uploadError: clearError ? null : (uploadError ?? this.uploadError),
    );
  }
}
