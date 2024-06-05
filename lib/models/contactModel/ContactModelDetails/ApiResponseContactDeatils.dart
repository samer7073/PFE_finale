import 'package:flutter_application_stage_project/models/contactModel/ContactModelDetails/info.dart';
import 'package:flutter_application_stage_project/models/contactModel/ContactModelDetails/relation.dart';

class ApiResponseContactDetails {
  final bool success;
  final Info info;
  final Relations relations;

  ApiResponseContactDetails(
      {required this.success, required this.info, required this.relations});

  factory ApiResponseContactDetails.fromJson(Map<String, dynamic> json) {
    return ApiResponseContactDetails(
      success: json['success'],
      info: Info.fromJson(json['info']),
      relations: Relations.fromJson(json['relations']),
    );
  }
}
