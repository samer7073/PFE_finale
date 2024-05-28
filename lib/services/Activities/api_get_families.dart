// lib/services/api_service.dart
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


Future<List<dynamic>> fetchFamilies() async {
final token = await SharedPrefernce.getToken("token"); 
  const String url = 'https://spherebackdev.cmk.biz:4543/api/mobile/get-families';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load modules: Status code ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load modules: $e');
    return [];
  }
}

Future<List<dynamic>> fetchRelatedModules(int moduleId) async {
final token =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5OWYxMWQxZS0xNjdhLTQ5OTMtOGZkNC01ODY4MGIwMDUzNjUiLCJqdGkiOiIxNGM5ZjQ1ZTYyODQ2MDYzMmQ4ZmY4MDU5MTZiMjYzNDk2MGEwMWQ5NDYyNWNkYjZiNzc3ZjYzMzJmNzc0ZjFlZWVmMmU2ODQ5MWIyYmIzZSIsImlhdCI6MTcxNTcxNzc0NC41NzEwMywibmJmIjoxNzE1NzE3NzQ0LjU3MTAzMywiZXhwIjoxNzE3MDEzNzQ0LjM5NDk2Nywic3ViIjoiOWJkNjVjMGQtOGIxYy00YTRhLTljMWEtMmVkNTZlNmM1Nzc2Iiwic2NvcGVzIjpbXSwiZW1haWwiOiJqaW1lZDIyMjU3QGV0b3B5cy5jb20iLCJuYW1lIjoiU2FtZXIgQXJmYW91aSJ9.L8xQt8Dj8DBPAiSmDC6cDYR-whw37N4cMwASdJ0UP6G_C3MkhIDNN_QV0M-sd15hOXMjHO5Tqoftlhtxlst2Mm3BHo-nDvkAZcw-Nws5DEQWLASp29uNFKHlvuXat-F9cJ2Kkj5UWzf7ZecWqHuIC5fjgmcKo3RXBGYqIJ-52MWhjEZVcAUoxp0BeXKSkedxfxHzgmHRdWeUXMjo5EW3Hdt2vxlXZ1vYcS4_y90B0XaIjivOpRZrhry1UWHFSLOX9PMj0JYnWaKsjI29ZiSb31fyyeRl4HZaFzj08CkFKcUL4qozPLlgajcNSE9Tzzn-SvGHqXE47x2XWjQb5KMsvgl9LX0rBTStwq0HJMTbw4KoQU5wJdkPAkbIKhcgeKSIARm5VN5ymHZ8mSe99j5eL1_yXxU99SzbjAvGWdI5YATc2NtnVBAiPBgUhfYeZd1HrtF2ibgYlGtHBn20K7e_mDi1OT8HEIb_4OQ2y_EhGKP9z458UEFeZxGp7RGIDAcba1RKZtHIN7_mF4Boqr-e2jRXrEGdhGSggubix_CUvkGVeeUoi2VV25BKr7VxZfEDI5iL1O9O4YioUs4fah6T49UpQrTnMvG0ACq1JHO9LaFo9XkM1v-hEHMGal2AaJzeWmx3ld4XecM-_ngMljjo49rKuGXw7HsfcIM03VSf_rI';
  
  final String url = 'https://spherebackdev.cmk.biz:4543/api/mobile/get-label-elements-by-family/$moduleId';

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to load related modules: Status code ${response.statusCode}');
    }
  } catch (e) {
    print('Failed to load related modules: $e');
    return [];
  }
}
