class Task {
  final int send_email;
  final String id;
  final String label;
  String priority;
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
  int? stageId;
  String stageLabel;
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
  final String iconColor;
  final bool isOverdue;
  final String? roomId;
  String stageColor;
  int stagePercent;
  final List<Upload> uploads;
  String task_type_icon;
  String task_type_label;
  String task_type_color;

  Task(
      {required this.id,
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
      required this.iconColor,
      this.isChecked = false,
      required this.isOverdue,
      this.roomId,
      this.stageColor = '#000000', // Valeur par défaut
      this.stagePercent = 0,
      required this.uploads, // Valeur par défaut
      required this.task_type_icon,
      required this.task_type_label,
      required this.task_type_color,
      required this.send_email});

  factory Task.fromJson(Map<String, dynamic> json,
      {int stagePercent = 0, String stageColor = '#000000'}) {
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
      iconColor: json['icon_color'] ?? '#000000',
      reminderBeforeEnd: json['reminder_before_end'] == null
          ? null
          : json['reminder_before_end'] == 1,
      isOverdue: json['is_overdue'] ?? false,
      roomId: json['room_id']?.toString(),
      stageColor: json['stage_color'] ?? stageColor,
      stagePercent: json['stage_percent'] ?? stagePercent,
      uploads: (json['upload'] as List<dynamic>?)
              ?.map((upload) => Upload.fromJson(upload))
              .toList() ??
          [],
      task_type_icon: json['task_type_icon'] ?? "",
      task_type_label: json['task_type_label'] ?? "",
      task_type_color: json['task_type_color'] ?? "#000000",
      send_email: json["send_email"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'priority': priority,
      'start_date': startDate,
      'end_date': endDate,
      'owner_avatar': ownerAvatar,
      'icon_color': iconColor,
      'tasks_type_id': tasksTypeId,
      'stage_label': stageLabel,
      'family_label': familyLabel,
      'element_label': elementLabel,
      'guests': guests,
      'followers': followers,
      'room_id': roomId, // Include roomId in JSON
    };
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

class Upload {
  final int id;
  final String fileName;
  final String path;
  final String taskId;

  Upload({
    required this.id,
    required this.fileName,
    required this.path,
    required this.taskId,
  });

  factory Upload.fromJson(Map<String, dynamic> json) {
    return Upload(
      id: json['id'] ?? 0,
      fileName: json['fileName'] ?? '',
      path: json['path'] ?? '',
      taskId: json['task_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'path': path,
      'task_id': taskId,
    };
  }
}
