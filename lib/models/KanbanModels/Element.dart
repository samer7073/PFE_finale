import 'package:flutter_application_stage_project/models/KanbanModels/Creator.dart';

class KanbanElement {
  final String elementId;
  final int familyId;
  final String? status;
  final int stageId;
  final int requiredFields;
  final int canCreateRoom;
  final String labelData;
  final Creator creator;
  final String reference;
  final String room_id;

  KanbanElement(
      {required this.elementId,
      required this.familyId,
      this.status,
      required this.stageId,
      required this.requiredFields,
      required this.canCreateRoom,
      required this.labelData,
      required this.creator,
      required this.reference,
      required this.room_id});

  factory KanbanElement.fromJson(Map<String, dynamic> json) {
    // Extract the reference value from the info list
    String reference = '';
    if (json['element_info']['info'] is List) {
      for (var item in json['element_info']['info']) {
        if (item.containsKey('Reference')) {
          reference = item['Reference'] ?? '';
          break;
        }
      }
    }

    return KanbanElement(
      elementId: json['element_id'] ?? '',
      familyId: json['family_id'] ?? 0,
      status: json['status'],
      stageId: json['stage_id'] ?? 0,
      requiredFields: json['required_fields'] ?? 0,
      canCreateRoom: json['can_create_room'] ?? 0,
      labelData: json['element_info']['label_data'] ?? '',
      creator: json['element_info']['creator'] != null
          ? Creator.fromJson(json['element_info']['creator'])
          : Creator(id: '', label: '', avatar: ''),
      reference: reference,
      room_id: "${json['room_id']}" ?? '',
    );
  }
}
