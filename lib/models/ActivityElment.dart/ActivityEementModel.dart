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
  int? stageId; // Changed to nullable
  String? stageLabel; // Changed to nullable
  String? pipelineLabel; // Changed to nullable
  bool isOverdue;
  List<dynamic> guests;
  List<dynamic> followers;
  CreatorActivityModel creator;
  String familyLabel;
  String elementLabel;
  String createdAt;
  String task_type_color;
  String task_type_icon;

  ActivityElment({
    required this.id,
    required this.label,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.tasksTypeId,
    required this.owner,
    this.priority = '', // Default value if null
    this.stageId, // Nullable field
    this.stageLabel, // Nullable field
    this.pipelineLabel, // Nullable field
    required this.isOverdue,
    required this.guests,
    required this.followers,
    required this.creator,
    required this.familyLabel,
    required this.elementLabel,
    required this.createdAt,
    required this.task_type_color,
    required this.task_type_icon,
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
        owner:
            OwnerActivityModel.fromJson(json['owner_id']), // Parse owner data
        priority: json['priority'] ?? '', // Provide default value if null
        stageId: json['stage_id'], // Nullable field
        stageLabel: json['stage_label'], // Nullable field
        pipelineLabel: json['pipeline_label'], // Nullable field
        isOverdue: json['is_overdue'],
        guests: json['guests'],
        followers: json['followers'],
        creator: CreatorActivityModel.fromJson(json['creator']),
        familyLabel: json['family_label'],
        elementLabel: json['element_label'],
        createdAt: json['created_at'],
        task_type_color: json['task_type_color'] ?? "",
        task_type_icon: json['task_type_icon'] ?? "");
  }
}
