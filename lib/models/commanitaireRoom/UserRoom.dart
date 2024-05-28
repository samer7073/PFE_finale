import 'config.dart';

class UserRoom {
  final int id;
  final String name;
  final String email;
  final String image;
  final String uuid;
  final String postNumber;
  final int availability;
  final Config config;
  final int status;

  UserRoom({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.uuid,
    required this.postNumber,
    required this.availability,
    required this.config,
    required this.status,
  });

  factory UserRoom.fromJson(Map<String, dynamic> json) {
    return UserRoom(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      uuid: json['uuid'] ?? '',
      postNumber: json['post_number'] ?? '',
      availability: json['availability'] ?? 0,
      config: Config.fromJson(json['config'] ?? {}),
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'uuid': uuid,
      'post_number': postNumber,
      'availability': availability,
      'config': config.toJson(),
      'status': status,
    };
  }
}
