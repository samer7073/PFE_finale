class Location {
  final int id;
  final String date_format;
  final String time_format;
  final String default_timezone;
  final String  default_language;
  final String week_started;
  final String dial_code;
  
  Location({required this.id, required this.date_format,required this.time_format,required this.default_timezone,required this.default_language,required this.dial_code,required this.week_started});
  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json["id"] ,
        date_format: json["date_format"] ?? "" ,
        time_format: json["time_format"] ?? "" ,
        default_timezone: json["default_timezone"] ?? "" ,
        default_language: json["default_language"] ?? "" ,
        week_started: json["week_started"] ?? "" ,
        dial_code: json["dial_code"] ?? "" ,
      );
}
