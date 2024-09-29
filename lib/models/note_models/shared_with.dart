class SharedWith {
  final String uuid;
  final String id;

  SharedWith({
    required this.uuid,
    required this.id,
  });

  factory SharedWith.fromJson(Map<String, dynamic> json) {
    return SharedWith(
      uuid: json['uuid'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}