class DetailResponse {
  final bool success;
  final Map<String, dynamic> data;

  DetailResponse({required this.success, required this.data});

  factory DetailResponse.fromJson(Map<String, dynamic> json) {
    return DetailResponse(
      success: json['success'],
      data: Map<String, dynamic>.from(json['data']),
    );
  }
}
