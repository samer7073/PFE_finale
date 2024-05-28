import 'package:flutter_application_stage_project/models/KanbanModels/Element.dart';

class KanbanResponse {
  final List<KanbanElement> data;

  KanbanResponse({required this.data});

  factory KanbanResponse.fromJson(Map<String, dynamic> json) {
    return KanbanResponse(
      data:
          (json['data'] as List).map((e) => KanbanElement.fromJson(e)).toList(),
    );
  }
}
