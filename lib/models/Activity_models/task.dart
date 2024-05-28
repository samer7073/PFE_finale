class Task {
  final String id;
  final String label;
  final String priority;
  final String creatorLabel;
  final String creatorAvatar;
  final String ownerId;
  final String ownerLabel;
  final String ownerAvatar;
  final String startDate;
  final int tasksTypeId;
  final String endDate;
  final String startTime;
  final String endTime;
  final String description;
  final String note;
  final int? stageId;
  final String stageLabel;
  final String pipelineLabel;
  final int? familyId;
  final String familyLabel;
  final String? elementId;
  final String elementLabel;
  final String createAt;
  final List<Map<String, dynamic>> guests;
  final List<Map<String, dynamic>> followers;
  bool isChecked;
  final bool? reminderBeforeEnd;
  final String location;
  final String reminder;

  Task({
    required this.id,
    required this.label,
    required this.priority,
    required this.creatorLabel,
    required this.creatorAvatar,
    required this.ownerId,
    required this.ownerLabel,
    required this.tasksTypeId,
    required this.ownerAvatar,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.description,
    required this.note,
    required this.stageId,
    required this.stageLabel,
    required this.pipelineLabel,
    required this.familyId,
    required this.familyLabel,
    required this.elementId,
    required this.elementLabel,
    required this.createAt,
    required this.guests,
    required this.followers,
    required this.reminderBeforeEnd,
    required this.location,
    required this.reminder,
    this.isChecked = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Handle both API structures for owner information
    String ownerId = '';
    String ownerLabel = '';
    String ownerAvatar = '';

    if (json['owner_id'] is Map) {
      ownerId = json['owner_id']?['id'] ?? '';
      ownerLabel = json['owner_id']?['label'] ?? '';
      ownerAvatar = json['owner_id']?['avatar'] ?? '';
    } else {
      ownerId = json['owner_id'] ?? '';
      ownerLabel = json['owner_label'] ?? '';
      ownerAvatar = json['owner_avatar'] ?? '';
    }

    return Task(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      priority: json['priority'] ?? '',
      creatorLabel: json['creator_label'] ?? '',
      creatorAvatar: json['creator_avatar'] ?? '',
      ownerId: ownerId,
      ownerLabel: ownerLabel,
      ownerAvatar: ownerAvatar,
      tasksTypeId: json['tasks_type_id'] ?? 0,
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      description: json['description'] ?? '',
      note: json['note'] ?? '',
      stageId: json['stage_id'],
      stageLabel: json['stage_label'] ?? '',
      pipelineLabel: json['pipeline_label'] ?? '',
      familyId: json['family_id'],
      familyLabel: json['family_label'] ?? '',
      elementId: json['element_id'],
      elementLabel: json['element_label'] ?? '',
      createAt: json['created_at'] ?? '',
      guests: List<Map<String, dynamic>>.from(json['guests'] ?? []),
      followers: List<Map<String, dynamic>>.from(json['followers'] ?? []),
      location: json['location'] ?? '',
      reminder: json['Reminder'] ?? '',
      reminderBeforeEnd: json['reminder_before_end'] == null
          ? null
          : json['reminder_before_end'] == 1,
    );
  }
}

class Guest {
  final String label;
  final String? avatar;

  Guest({required this.label, this.avatar});

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      label: json['label'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class Follower {
  final String label;
  final String? avatar;

  Follower({required this.label, this.avatar});

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      label: json['label'] ?? '',
      avatar: json['avatar'],
    );
  }
}
