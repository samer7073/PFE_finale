class Email {
  final String label;
  final int field_id;
  Email({required this.field_id, required this.label});
  factory Email.fromJson(Map<String, dynamic> json) => Email(
        label: json["label"] ?? "",
        field_id: json["field_id"] ?? 0,
      );
}
