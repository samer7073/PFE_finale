class Info {
  final String label;
  final String email;
  final String phoneNumber;

  Info({required this.label, required this.email, required this.phoneNumber});

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      label: " ${json['label']}",
      email: "${json['email']}",
      phoneNumber: "${json['phone_number']}",
    );
  }
}
