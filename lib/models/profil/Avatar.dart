class Avatar {
  final String label;
  final int field_id;
  Avatar({required this.field_id, required this.label});
  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
        label: json["label"] ?? "",
        field_id: json["field_id"] ?? "",
      );
}
