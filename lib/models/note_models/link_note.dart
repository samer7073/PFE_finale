class LinkNote {
  final String? url; // Nullable
  final String label;
  final bool active;

  LinkNote({
    this.url,
    required this.label,
    required this.active,
  });

  factory LinkNote.fromJson(Map<String, dynamic> json) {
    return LinkNote(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}