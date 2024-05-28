import 'package:flutter_application_stage_project/models/ActivityElment.dart/ActivityEementModel.dart';

class ActivityResponse {
  final List<ActivityElment> data;
  ActivityResponse({required this.data});
  factory ActivityResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<ActivityElment> element =
        list.map((i) => ActivityElment.fromJson(i)).toList();

    return ActivityResponse(
      data: element,
    );
  }
}
