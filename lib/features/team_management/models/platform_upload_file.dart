class PlatformUploadFile {
  final String name;
  final List<int> bytes;
  final String? path; // null jika di web
  final String jenis; // 'poster' atau 'panduan'

  const PlatformUploadFile({
    required this.name,
    required this.bytes,
    this.path,
    this.jenis = 'poster',
  });

  /// Ukuran file dalam megabytes (MB)
  double get sizeInMb => bytes.length / (1024 * 1024);

  /// Teks ukuran file yang rapi (contoh: "1.45 MB" atau "850 KB")
  String get formattedSize {
    if (bytes.length < 1024 * 1024) {
      return '${(bytes.length / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes.length / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Mengecek apakah file melebihi 10 MB (10 * 1024 * 1024 bytes)
  bool get isExceeds10Mb => bytes.length > 10 * 1024 * 1024;
}

