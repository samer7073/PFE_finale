class StageKpiModel {
  final String stageLabel;
  final int stageCount;
  final String stage_color;

  StageKpiModel({
    required this.stageLabel,
    required this.stageCount,
    required this.stage_color,
  });

  factory StageKpiModel.fromJson(Map<String, dynamic> json) {
    return StageKpiModel(
      stageLabel: json['stage_label'],
      stageCount: json['stage_count'],
      stage_color: json['stage_color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage_label': stageLabel,
      'stage_count': stageCount,
    };
  }
}
