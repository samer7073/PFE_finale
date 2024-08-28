import 'package:flutter_application_stage_project/models/commanitaireRoom/Links.dart';
import 'package:flutter_application_stage_project/models/commanitaireRoom/Message.dart';
import 'package:flutter_application_stage_project/models/commanitaireRoom/Meta.dart';

class ApiResponseRoom {
  final List<Message> data;
  final Links links;
  final Meta meta;
  final bool success;

  ApiResponseRoom({required this.data, required this.links, required this.meta, required this.success});

  factory ApiResponseRoom.fromJson(Map<String, dynamic> json) {
    return ApiResponseRoom(
      data: (json['data'] as List? ?? []).map((item) => Message.fromJson(item)).toList(),
      links: Links.fromJson(json['links'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
      success: json['success'] ?? false,
    );
  }
}