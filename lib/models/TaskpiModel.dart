class TaskKpiModel {
  int? today;
  int? thisWeek;
  int? tomorrow;
  int? upcoming;
  int? created;
  int? invited;
  int? isOverdue;
  int? visio;

  TaskKpiModel({
    this.today,
    this.thisWeek,
    this.tomorrow,
    this.upcoming,
    this.created,
    this.invited,
    this.isOverdue,
    this.visio,
  });

  // Méthode pour convertir un objet JSON en instance de ApiResponse
  factory TaskKpiModel.fromJson(Map<String, dynamic> json) {
    return TaskKpiModel(
      today: json['today'] as int?,
      thisWeek: json['this_week'] as int?,
      tomorrow: json['tomorrow'] as int?,
      upcoming: json['upcoming'] as int?,
      created: json['created'] as int?,
      invited: json['invited'] as int?,
      isOverdue: json['is_overdue'] as int?,
      visio: json['visio'] as int?,
    );
  }

  // Méthode pour convertir une instance de ApiResponse en objet JSON
  Map<String, dynamic> toJson() {
    return {
      'today': today,
      'this_week': thisWeek,
      'tomorrow': tomorrow,
      'upcoming': upcoming,
      'created': created,
      'invited': invited,
      'is_overdue': isOverdue,
      'visio': visio,
    };
  }
}
