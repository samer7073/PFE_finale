class ApiResponseJwt {
  String uuid;
  String jwtMercure;

  ApiResponseJwt({
    required this.uuid,
    required this.jwtMercure,
  });

  factory ApiResponseJwt.fromJson(Map<String, dynamic> json) {
    return ApiResponseJwt(
      uuid: json['user']['uuid'],
      jwtMercure: json['jwt_mercure'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'jwt_mercure': jwtMercure,
    };
  }
}
