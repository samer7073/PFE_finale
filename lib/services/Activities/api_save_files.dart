import 'dart:developer';
import 'package:dio/dio.dart';
import '../../core/constants/shared/config.dart';
import '../sharedPreference.dart';

class SaveFiles {
  static Future<List<int>?> saveFiles(Map<String, dynamic> data) async {
    final token = await SharedPrefernce.getToken("token");
    final apiUrl = await Config.getApiUrl("saveFile");
    log("save api here ");

    try {
      final baseOptions = BaseOptions(
        baseUrl: apiUrl,
        contentType: Headers.jsonContentType,
        validateStatus: (int? status) {
          return status != null;
        },
      );

      Dio dio = Dio(baseOptions);

      // Créez FormData à partir de la carte de données
      var formData = FormData.fromMap(data);

      Response response = await dio.post(
        apiUrl,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      log("here the response -----  ${response.statusCode}");
      log("response data: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        List<int> ids = [];
        for (var fileData in response.data["data"]) {
          ids.add(fileData["id"]);
        }
        return ids;
      } else {
        return null;
      }
    } catch (e) {
      print('Error while performing file post request: $e');
      return null;
    }
  }
}
