import 'package:flutter_application_stage_project/models/KpiFamily/StageKpiModel.dart';

class PipelineKpiModel {
  final String pipeline;
  final int total;
  final List<StageKpiModel> stages;

  PipelineKpiModel({
    required this.pipeline,
    required this.total,
    required this.stages,
  });

  factory PipelineKpiModel.fromJson(Map<String, dynamic> json) {
    var list = json['stages'] as List;
    List<StageKpiModel> stageList =
        list.map((i) => StageKpiModel.fromJson(i)).toList();

    return PipelineKpiModel(
      pipeline: json['pipeline'],
      total: json['total'],
      stages: stageList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pipeline': pipeline,
      'total': total,
      'stages': stages.map((stage) => stage.toJson()).toList(),
    };
  }
}
