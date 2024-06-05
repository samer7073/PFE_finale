class Deal {
  final String id;
  final String label;

  Deal({required this.id, required this.label});

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'],
      label: json['label'],
    );
  }
}
