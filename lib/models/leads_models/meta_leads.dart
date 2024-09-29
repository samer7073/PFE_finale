import 'package:flutter_application_stage_project/models/leads_models/links_leads.dart';

class MetaLeads {
  final int currentPage;
  final int from;
  final int lastPage;
  final List<LinksLeads> links;
  final String path;
  final int perPage;
  final int to;
  final int total;

  MetaLeads({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory MetaLeads.fromJson(Map<String, dynamic> json) {
    return MetaLeads(
      currentPage: json['current_page'] ?? 0,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      links: List<LinksLeads>.from(json['links'].map((link) => LinksLeads.fromJson(link))),
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 0,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}