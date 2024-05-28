class Stage {
  final int id;
  final String label;
  final String color;

  Stage({
    required this.id,
    required this.label,
    required this.color,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'],
      label: json['label'],
      color: json['color'],
    );
  }
}