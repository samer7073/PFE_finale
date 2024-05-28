class CreatorActivityModel {
  String id;
  String label;
  String avatar;
  String familyName;

  CreatorActivityModel({
    required this.id,
    required this.label,
    required this.avatar,
    required this.familyName,
  });

  factory CreatorActivityModel.fromJson(Map<String, dynamic> json) {
    return CreatorActivityModel(
      id: json['id'],
      label: json['label'],
      avatar: json['avatar'],
      familyName: json['family_name'],
    );
  }
}
