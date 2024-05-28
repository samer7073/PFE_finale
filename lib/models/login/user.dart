import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class User {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String email_verified_at;
  final String provider;
  final String application;
  final String role;
  final int status;
  final String created_at;
  final String updated_at;
  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.email_verified_at,
    required this.provider,
    required this.application,
    required this.role,
    required this.status,
    required this.created_at,
    required this.updated_at,
  });
  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"]?? "",
        phone: json["phone"]?? "",
        email: json["email"]?? "",
        email_verified_at: json["email_verified_at"] ?? "",
        provider: json["provider"]?? "",
        application: json["application"]?? "",
        role: json["role"]?? "",
        status:
            json["status"] ?? "", // TODO: Get the correct locale from user settings
        created_at: json["created_at"]?? "",
        updated_at: json["updated_at"]?? "",
      );
}
