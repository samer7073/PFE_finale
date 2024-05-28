import 'stageModel.dart';

class Pipeline {
  final int id;
  final String label;
  final List<Stage> stages;

  Pipeline({
    required this.id,
    required this.label,
    required this.stages,
  });

  factory Pipeline.fromJson(Map<String, dynamic> json) {
    var list = json['stages'] as List;
    List<Stage> stagesList = list.map((i) => Stage.fromJson(i)).toList();

    return Pipeline(
      id: json['id'],
      label: json['label'],
      stages: stagesList,
    );
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pipeline && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
