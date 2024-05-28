import 'package:flutter_application_stage_project/models/commanitaireRoom/Meta.dart';

import 'Links.dart';
import 'Message.dart';

class RoomResponse {
  final List<Message> data;
  final Links links;
  final Meta meta;
  final bool success;

  RoomResponse({
    required this.data,
    required this.links,
    required this.meta,
    required this.success,
  });

  factory RoomResponse.fromJson(Map<String, dynamic> json) {
    var dataFromJson = json['data'] as List;
    List<Message> dataList =
        dataFromJson.map((message) => Message.fromJson(message)).toList();

    return RoomResponse(
      data: dataList,
      links: Links.fromJson(json['links'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((message) => message.toJson()).toList(),
      'links': links.toJson(),
      'meta': meta.toJson(),
      'success': success,
    };
  }
}
