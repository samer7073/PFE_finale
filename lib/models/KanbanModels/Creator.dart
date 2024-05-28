class Creator {
  String id;
  String label;
  String avatar;

  Creator({
    required this.id,
    required this.label,
    required this.avatar,
  });

  factory Creator.fromJson(Map<String, dynamic> json) {
    return Creator(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'avatar': avatar,
    };
  }
}
