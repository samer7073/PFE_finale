import 'dart:convert';

import 'package:flutter_application_stage_project/models/dataOuverveiwModel.dart';

class OverviewModelRespone {
  final List<DataOverviewModel> data;

  OverviewModelRespone({required this.data});

  factory OverviewModelRespone.fromJson(Map<String, dynamic> json) {
    return OverviewModelRespone(
      data: List<DataOverviewModel>.from(
          json['data'].map((item) => DataOverviewModel.fromJson(item))),
    );
  }
}
