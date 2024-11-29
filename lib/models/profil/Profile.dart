import 'package:flutter_application_stage_project/models/profil/Avatar.dart';
import 'package:flutter_application_stage_project/models/profil/Email.dart';
import 'package:flutter_application_stage_project/models/profil/Name.dart';
import 'package:flutter_application_stage_project/models/profil/PhoneNumber.dart';
import 'package:flutter_application_stage_project/models/profil/location.dart';

class Profile {
  final Name name;
  final Email email;
  final Avatar avatar;
  final PhoneNumber phone_number;
  final String uuid;
  final Location location;
  Profile(
      {required this.name,
      required this.email,
      required this.avatar,
      required this.phone_number,
      required this.uuid,required this.location});
  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        name: Name.fromJson(json["name"]),
        email: Email.fromJson(json["email"]),
        avatar: Avatar.fromJson(json["avatar"]),
        phone_number: PhoneNumber.fromJson(json["phone_number"]),
        uuid: json["uuid"],
        location: Location.fromJson(json["location"]),
      );
}
