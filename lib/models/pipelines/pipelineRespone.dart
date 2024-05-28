import 'pipelineModel.dart';

class PipelineResponse {
  final bool success;
  final List<Pipeline> data;

  PipelineResponse({
    required this.success,
    required this.data,
  });

  factory PipelineResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Pipeline> dataList = list.map((i) => Pipeline.fromJson(i)).toList();

    return PipelineResponse(
      success: json['success'],
      data: dataList,
    );
  }
}
