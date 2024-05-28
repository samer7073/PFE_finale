class StageKpiModel {
  final String stageLabel;
  final int stageCount;

  StageKpiModel({
    required this.stageLabel,
    required this.stageCount,
  });

  factory StageKpiModel.fromJson(Map<String, dynamic> json) {
    return StageKpiModel(
      stageLabel: json['stage_label'],
      stageCount: json['stage_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage_label': stageLabel,
      'stage_count': stageCount,
    };
  }
}
