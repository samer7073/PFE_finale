import 'package:flutter_application_stage_project/models/contactModel/data.dart';
import 'package:flutter_application_stage_project/models/contactModel/links.dart';
import 'package:flutter_application_stage_project/models/contactModel/meta.dart';

class ApiResponseContact {
  final List<Data> data;
  final Links links;
  final Meta meta;

  ApiResponseContact(
      {required this.data, required this.links, required this.meta});

  factory ApiResponseContact.fromJson(Map<String, dynamic> json) {
    return ApiResponseContact(
      data: (json['data'] as List).map((item) => Data.fromJson(item)).toList(),
      links: Links.fromJson(json['links']),
      meta: Meta.fromJson(json['meta']),
    );
  }
}
