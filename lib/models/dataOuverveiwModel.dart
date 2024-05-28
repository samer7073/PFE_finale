class DataOverviewModel {
  final String user;
  final String action;
  final String date;
  final String labelData;
  final String type;
  //final int familyId;
  final String actionType;
  //final Map<String, List<String>> changes;

  DataOverviewModel({
    required this.user,
    required this.action,
    required this.date,
    required this.labelData,
    required this.type,
    //required this.familyId,
    required this.actionType,
    //required this.changes,
  });

  factory DataOverviewModel.fromJson(Map<String, dynamic> json) {
    /*
    Map<String, List<String>> changesMap = {};
    if (json['changes'] != null) {
      json['changes'].forEach((key, value) {
        changesMap[key] = List<String>.from(value);
      });
    }
    */
    return DataOverviewModel(
      user: json['user'] ?? 'default_user',
      action: json['action'] ?? 'default_action',
      date: json['date'] ?? 'default_date',
      labelData: json['label_data'] ?? 'default_label',
      type: json['type'] ?? 'default_type',
      //familyId: json['family_id'] ?? 0,
      actionType: json['action_type'] ?? 'default_action_type',
      //changes: changesMap,
    );
  }
}
