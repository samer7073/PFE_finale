import 'package:flutter_application_stage_project/models/fields/datafieldgroup.dart';

class DataFieldGroupResponse {
  final List<DataFieldGroup> data;
  DataFieldGroupResponse(this.data);
  factory DataFieldGroupResponse.fromJson(List<dynamic> json) {
    final List<DataFieldGroup> fieldgroup =
        json.map((item) => DataFieldGroup.fromJson(item)).toList();
    return DataFieldGroupResponse(fieldgroup);
  }
}
