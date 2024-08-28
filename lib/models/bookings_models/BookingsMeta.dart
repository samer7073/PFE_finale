class Bookingsmeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final List<Map<String, dynamic>> links;
  final String path;
  final int perPage;
  final int to;
  final int total;

  Bookingsmeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Bookingsmeta.fromJson(Map<String, dynamic> json) {
    return Bookingsmeta(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      links: List<Map<String, dynamic>>.from(json['links']),
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }
}
