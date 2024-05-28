class Info {
  final String label;
  final String avatar;
  final String? familyLabel;

  Info({required this.label, required this.avatar, this.familyLabel});

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      label: json['label'],
      avatar: json['avatar'],
      familyLabel: json['family_label'],
    );
  }
}
