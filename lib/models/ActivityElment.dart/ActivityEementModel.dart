import 'CreatorActivityModel.dart';
import 'OwnerActivityModel.dart';

class ActivityElment {
  String id;
  String label;
  String startDate;
  String startTime;
  String endDate;
  String endTime;
  int tasksTypeId;
  OwnerActivityModel owner;
  String priority;
  int stageId;
  String stageLabel;
  String pipelineLabel;
  bool isOverdue;
  List<dynamic> guests;
  List<dynamic> followers;
  CreatorActivityModel creator;
  String familyLabel;
  String elementLabel;
  String createdAt;

  ActivityElment({
    required this.id,
    required this.label,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.tasksTypeId,
    required this.owner,
    required this.priority,
    required this.stageId,
    required this.stageLabel,
    required this.pipelineLabel,
    required this.isOverdue,
    required this.guests,
    required this.followers,
    required this.creator,
    required this.familyLabel,
    required this.elementLabel,
    required this.createdAt,
  });

  factory ActivityElment.fromJson(Map<String, dynamic> json) {
  return ActivityElment(
    id: json['id'],
    label: json['label'],
    startDate: json['start_date'],
    startTime: json['start_time'],
    endDate: json['end_date'],
    endTime: json['end_time'],
    tasksTypeId: json['tasks_type_id'],
    owner: OwnerActivityModel.fromJson(json['owner_id']), // Parse owner data
    priority: json['priority'] ?? "",
    stageId: json['stage_id'],
    stageLabel: json['stage_label'],
    pipelineLabel: json['pipeline_label'],
    isOverdue: json['is_overdue'],
    guests: json['guests'],
    followers: json['followers'],
    creator: CreatorActivityModel.fromJson(json['creator']),
    familyLabel: json['family_label'],
    elementLabel: json['element_label'],
    createdAt: json['created_at'],
  );
}

}
