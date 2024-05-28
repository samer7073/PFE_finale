// pipeline_model.dart
class Pipeline {
  final int id;
  final String label;
  final List<Stage> stages;

  Pipeline({required this.id, required this.label, required this.stages});

  factory Pipeline.fromJson(Map<String, dynamic> json) {
    var list = json['stages'] as List;
    List<Stage> stagesList = list.map((i) => Stage.fromJson(i)).toList();

    return Pipeline(
      id: json['id'],
      label: json['label'],
      stages: stagesList,
    );
  }
}

class Stage {
  final int id;
  final String label;
  final String color;

  Stage({required this.id, required this.label, required this.color});

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'],
      label: json['label'],
      color: json['color'],
    );
  }
}

