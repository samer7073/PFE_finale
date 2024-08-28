class MetaLink {
  final String? url;
  final String label;
  final bool active;

  MetaLink({this.url, required this.label, required this.active});

  factory MetaLink.fromJson(Map<String, dynamic> json) {
    return MetaLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }
}