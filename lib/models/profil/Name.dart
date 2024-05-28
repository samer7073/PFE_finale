class Name {
  final String label;
  final int field_id;
  Name({required this.field_id, required this.label});
  factory Name.fromJson(Map<String, dynamic> json) => Name(
        label: json["label"] ?? "",
        field_id: json["field_id"] ?? 0,
      );
}
