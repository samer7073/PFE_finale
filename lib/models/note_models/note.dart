import 'package:flutter_application_stage_project/models/note_models/data_user_note.dart';
import 'package:flutter_application_stage_project/models/note_models/shared_with.dart';

class Note {
  final String id;
  final String user;
  final String? object; // Nullable
  final String content;
  final String? priority; // Nullable
  final DataUserNote dataUser;
  final int statusNote;
  final String? moduleNote; // Nullable
  final String? familyId; // Nullable
  final String? elementId; // Nullable
  final String? labelElement; // Nullable
  final String? voice; // Nullable
  final int shared;
  final DateTime updatedAt;
  final DateTime createdAt;
  final DateTime? reminderDate; // Nullable
  final int permission;
  final List<SharedWith> sharedWith; // Nouvelle propriété

  Note({
    required this.id,
    required this.user,
    this.object,
    required this.content,
    this.priority,
    required this.dataUser,
    required this.statusNote,
    this.moduleNote,
    this.familyId,
    this.elementId,
    this.labelElement,
    this.voice,
    required this.shared,
    required this.updatedAt,
    required this.createdAt,
    this.reminderDate,
    required this.permission,
    required this.sharedWith, // Nouvelle propriété
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    var sharedWithList = json['shared_with'] as List? ?? [];
    List<SharedWith> sharedWith = sharedWithList.map((sharedJson) => SharedWith.fromJson(sharedJson)).toList();

    return Note(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      object: json['object'],
      content: json['content'] ?? '',
      priority: json['priority'],
      dataUser: DataUserNote.fromJson(json['dataUser']),
      statusNote: json['status_note'] ?? 0,
      moduleNote: json['module_note'],
      familyId: json['family_id'],
      elementId: json['element_id'],
      labelElement: json['label_element'],
      voice: json['voice'],
      shared: json['shared'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      reminderDate: json['reminder_date'] != null ? DateTime.parse(json['reminder_date']) : null,
      permission: json['permission'] ?? 0,
      sharedWith: sharedWith, // Nouvelle propriété
    );
  }
}