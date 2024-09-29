class AvatarNote {
  final String fileName;
  final String path;

  AvatarNote({
    required this.fileName,
    required this.path,
  });

  factory AvatarNote.fromJson(Map<String, dynamic> json) {
    return AvatarNote(
      fileName: json['file_name'] ?? '',
      path: json['path'] ?? '',
    );
  }
}