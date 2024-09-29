import 'package:flutter_application_stage_project/models/leads_models/lead.dart';
import 'package:flutter_application_stage_project/models/leads_models/links_leads.dart';
import 'package:flutter_application_stage_project/models/leads_models/meta_leads.dart';

class LeadsResponse {
  final List<Lead> data;
  final LinksLeads links;
  final MetaLeads meta;

  LeadsResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory LeadsResponse.fromJson(Map<String, dynamic> json) {
    return LeadsResponse(
      data: List<Lead>.from(json['data'].map((lead) => Lead.fromJson(lead))),
      links: LinksLeads.fromJson(json['links']),
      meta: MetaLeads.fromJson(json['meta']),
    );
  }
}
