import 'package:intl/intl.dart';

class Token {
  final String token_type;
  final int expires_in;
  final String access_token;
  final String refresh_token;
  Token(
      {required this.token_type,
      required this.expires_in,
      required this.access_token,
      required this.refresh_token});
  factory Token.fromJson(Map<String, dynamic> json) => Token(
      token_type: json["token_type"],
      expires_in: json["expires_in"],
      access_token: json["access_token"],
      refresh_token: json["refresh_token"]);
}
