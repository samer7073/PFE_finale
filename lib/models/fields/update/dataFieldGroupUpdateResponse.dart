import 'package:flutter_application_stage_project/models/fields/update/dataFieldGroupUpdate.dart';

class DataFieldGroupUpdateResponse {
  final List<DataFieldGroupUpdate> data;
  DataFieldGroupUpdateResponse(this.data);
  factory DataFieldGroupUpdateResponse.fromJson(List<dynamic> json) {
    final List<DataFieldGroupUpdate> fieldgroup =
        json.map((item) => DataFieldGroupUpdate.fromJson(item)).toList();
    return DataFieldGroupUpdateResponse(fieldgroup);
  }
}
