class BookingsLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  BookingsLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory BookingsLinks.fromJson(Map<String, dynamic> json) {
    return BookingsLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}
