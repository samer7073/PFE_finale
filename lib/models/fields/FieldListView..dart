class FieldListView {
  final int id;
  final String label;
  FieldListView({required this.id, required this.label});
  factory FieldListView.formJson(Map<String, dynamic> json) => FieldListView(
        id: json['id'],
        label: json['label'],
      );
}
