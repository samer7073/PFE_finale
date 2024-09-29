import 'package:flutter_application_stage_project/models/note_models/avtar_note.dart';

class DataUserNote {
  final String labelData;
  final AvatarNote avatar;

  DataUserNote({
    required this.labelData,
    required this.avatar,
  });

  factory DataUserNote.fromJson(Map<String, dynamic> json) {
    return DataUserNote(
      labelData: json['label_data'] ?? '',
      avatar: AvatarNote.fromJson(json['avatar']),
    );
  }
}