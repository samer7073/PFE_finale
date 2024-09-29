import 'package:flutter_application_stage_project/models/note_models/link_note.dart';
import 'package:flutter_application_stage_project/models/note_models/note.dart';

class NotesData {
  final int currentPage;
  final List<Note> notes;
  final String firstPageUrl;
  final int from;
  final int lastPage;
  final String lastPageUrl;
  final List<LinkNote> links;
  final String? nextPageUrl; // Nullable
  final String path;
  final int perPage;
  final String? prevPageUrl; // Nullable
  final int to;
  final int total;

  NotesData({
    required this.currentPage,
    required this.notes,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory NotesData.fromJson(Map<String, dynamic> json) {
    var notesList = json['data'] as List? ?? [];
    List<Note> notes = notesList.map((noteJson) => Note.fromJson(noteJson)).toList();

    var linksList = json['links'] as List? ?? [];
    List<LinkNote> links = linksList.map((linkJson) => LinkNote.fromJson(linkJson)).toList();

    return NotesData(
      currentPage: json['current_page'] ?? 1,
      notes: notes,
      firstPageUrl: json['first_page_url'] ?? '',
      from: json['from'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      lastPageUrl: json['last_page_url'] ?? '',
      links: links,
      nextPageUrl: json['next_page_url'], // Nullable
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 15,
      prevPageUrl: json['prev_page_url'], // Nullable
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}