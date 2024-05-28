import 'dart:convert';
import 'dart:developer';

import 'package:flutter_application_stage_project/models/fields/datafieldgroupresponse.dart';
import 'package:flutter_application_stage_project/models/fields/datafieldsresponse.dart';
import 'package:flutter_application_stage_project/models/fields/update/dataFieldGroupUpdate.dart';
import 'package:flutter_application_stage_project/models/fields/update/dataFieldGroupUpdateResponse.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;

class ApiField {
  static Future<DataFieldGroupResponse> getFeildsData(String groupId) async {
    final token = await SharedPrefernce.getToken("token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-fields-by-group/$groupId";
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log(responseData.toString());
      return DataFieldGroupResponse.fromJson(responseData['data']);
    } else {
      throw Exception('Failed to load fields');
    }
  }

  static Future<DataFieldGroupUpdateResponse> getFeildsDataToUpdate(
      String groupId, String Element_id) async {
    final token = await SharedPrefernce.getToken("token");
    final url =
        "https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-fields-by-group/$groupId?element_id=$Element_id";
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      log(responseData.toString());
      return DataFieldGroupUpdateResponse.fromJson(responseData['data']);
    } else {
      throw Exception('Failed to load fields');
    }
  }
}
