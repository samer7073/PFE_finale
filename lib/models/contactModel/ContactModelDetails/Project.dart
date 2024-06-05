class Project {
  final String id;
  final String label;

  Project({required this.id, required this.label});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      label: json['label'],
    );
  }
}
