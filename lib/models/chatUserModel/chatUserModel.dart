class ChatUser {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String? uuid;
  final int? postNumber;
  final int? availability;
  final int status;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.uuid,
    this.postNumber,
    this.availability,
    required this.status,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      image: json['image'],
      uuid: json['uuid'],
      postNumber: json['post_number'],
      availability: json['availability'],
      status: json['status'],
    );
  }

  get sender => null;
}
