import 'package:flutter_application_stage_project/models/contactModel/ContactModelDetails/deal.dart';

class Relations {
  final List<Deal> deal;
  final List<dynamic> helpdesk;
  final List<dynamic> project;

  Relations(
      {required this.deal, required this.helpdesk, required this.project});

  factory Relations.fromJson(Map<String, dynamic> json) {
    return Relations(
      deal: (json['Deal'] as List).map((item) => Deal.fromJson(item)).toList(),
      helpdesk: (json['Helpdesk'] as List)
          .map((item) => Deal.fromJson(item))
          .toList(),
      project:
          (json['Project'] as List).map((item) => Deal.fromJson(item)).toList(),
    );
  }
}
