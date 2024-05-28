import 'MetaLink.dart';

class Meta {
  final int currentPage;
  final int from;
  final int lastPage;
  final List<MetaLink> links;
  final String path;
  final int perPage;
  final int to;
  final int total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    var linksFromJson = json['links'] as List;
    List<MetaLink> linksList =
        linksFromJson.map((link) => MetaLink.fromJson(link)).toList();

    return Meta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      links: linksList,
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 15,
      to: json['to'] ?? 1,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'links': links.map((link) => link.toJson()).toList(),
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }
}
