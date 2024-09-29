class LinksLeads {
    final String? first;
  final String? last;
  final String? prev;
  final String? next;

  LinksLeads({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory LinksLeads.fromJson(Map<String, dynamic> json) {
    return LinksLeads(
      first: json['first'] ?? "",
      last: json['last']?? "",
      prev: json['prev'] ?? "",
      next: json['next'] ?? "",
    );
  }
}