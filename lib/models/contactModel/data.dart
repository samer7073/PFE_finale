class Data {
  final String id;
  final String label;
  final String avatar;
  final String familyLabel;

  Data(
      {required this.id,
      required this.label,
      required this.avatar,
      required this.familyLabel});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['id'],
      label: json['label'],
      avatar: json['avatar'],
      familyLabel: json['family_label'],
    );
  }
}
