// pipeline_model.dart
class Pipeline {
  final int id;
  final String label;
  final List<Stage> stages;
  final int percent;

  Pipeline(
      {required this.id,
      required this.label,
      required this.stages,
      required this.percent});

  factory Pipeline.fromJson(Map<String, dynamic> json) {
    var list = json['stages'] as List;
    List<Stage> stagesList = list.map((i) => Stage.fromJson(i)).toList();

    return Pipeline(
      id: json['id'],
      label: json['label'],
      stages: stagesList,
      percent: json['percent'] ?? 0,
    );
  }
}

class Stage {
  int id;
  String label;
  String color;
  int percent;

  Stage({
    required this.id,
    required this.label,
    required this.color,
    required this.percent,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'],
      label: json['label'],
      color: json['color'],
      percent: json['percent'] ?? -1,
    );
  }

  // Getters
  int get getId => id;
  String get getLabel => label;
  String get getColor => color;
  int get getPercent => percent;

  // Setters
  set setId(int value) => id = value;
  set setLabel(String value) => label = value;
  set setColor(String value) => color = value;
  set setPercent(int value) => percent = value;
}
