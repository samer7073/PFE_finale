import 'package:flutter_application_stage_project/models/KpiFamily/PipelineKpiModel.dart';

class KpiResponseModel {
  final bool success;
  final int total;
  final List<PipelineKpiModel> data;

  KpiResponseModel({
    required this.success,
    required this.total,
    required this.data,
  });

  factory KpiResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<PipelineKpiModel> pipelineList =
        list.map((i) => PipelineKpiModel.fromJson(i)).toList();

    return KpiResponseModel(
      success: json['success'],
      total: json['total'],
      data: pipelineList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'total': total,
      'data': data.map((pipeline) => pipeline.toJson()).toList(),
    };
  }
}
