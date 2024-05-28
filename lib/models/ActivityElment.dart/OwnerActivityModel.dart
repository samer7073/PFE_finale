class OwnerActivityModel {
  String id;
  String label;
  String avatar;
  String familyName;

  OwnerActivityModel({
    required this.id,
    required this.label,
    required this.avatar,
    required this.familyName,
  });

  factory OwnerActivityModel.fromJson(Map<String, dynamic> json) {
    return OwnerActivityModel(
      id: json['id'],
      label: json['label'],
      avatar: json['avatar'],
      familyName: json['family_name'],
    );
  }
}
