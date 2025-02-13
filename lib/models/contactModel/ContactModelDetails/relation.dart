import 'package:flutter_application_stage_project/models/contactModel/ContactModelDetails/Project.dart';
import 'package:flutter_application_stage_project/models/contactModel/ContactModelDetails/deal.dart';
import 'package:flutter_application_stage_project/models/contactModel/ContactModelDetails/helpdesk.dart';

class Relations {
  final List<Deal> deal;
  final List<Helpdesk> helpdesk;
  final List<Project> project;

  Relations(
      {required this.deal, required this.helpdesk, required this.project});

  factory Relations.fromJson(Map<String, dynamic> json) {
    return Relations(
      deal: (json['Deal'] as List).map((item) => Deal.fromJson(item)).toList(),
      helpdesk: (json['Helpdesk'] as List)
          .map((item) => Helpdesk.fromJson(item))
          .toList(),
      project: (json['Project'] as List)
          .map((item) => Project.fromJson(item))
          .toList(),
    );
  }
}
