import 'package:flutter_application_stage_project/models/note_models/notes_data.dart';

class NotesResponse {
  final bool success;
  final NotesData data;
  final int message;

  NotesResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory NotesResponse.fromJson(Map<String, dynamic> json) {
    return NotesResponse(
      success: json['success'] ?? false,
      data: NotesData.fromJson(json['data']),
      message: json['message'] ?? 0,
    );
  }
}