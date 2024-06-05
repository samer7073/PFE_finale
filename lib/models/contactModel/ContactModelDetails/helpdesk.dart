class Helpdesk {
  final String id;
  final String label;

  Helpdesk({required this.id, required this.label});

  factory Helpdesk.fromJson(Map<String, dynamic> json) {
    return Helpdesk(
      id: json['id'],
      label: json['label'],
    );
  }
}
