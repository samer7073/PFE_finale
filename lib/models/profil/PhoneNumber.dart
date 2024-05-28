class PhoneNumber {
  final List<dynamic> label;
  final int field_id;
  PhoneNumber({required this.field_id, required this.label});
  factory PhoneNumber.fromJson(Map<String, dynamic> json) => PhoneNumber(
        label: json["label"] ?? [],
        field_id: json["field_id"] ?? 0,
      );
}
