class FamilyModuleData {
  final int id;
  final String label;
  FamilyModuleData({required this.id, required this.label});
  factory FamilyModuleData.fromJson(Map<String, dynamic> json) =>
      FamilyModuleData(id: json["id"], label: json["label"]);
}
