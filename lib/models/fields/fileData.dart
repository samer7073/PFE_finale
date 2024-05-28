class DataFields {
  final int id;
  final String label;
  bool isExpanded; // Supprimez 'late' du champ isExpanded

  DataFields({required this.id, required this.label, this.isExpanded = false});

  factory DataFields.fromJson(Map<String, dynamic> json) =>
      DataFields(id: json['id'], label: json['label'] ?? "");
}
