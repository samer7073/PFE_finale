import 'package:flutter_application_stage_project/models/commanitaireRoom/UserRoom.dart';

class Message {
  final int id;
  final String type;
  final int? parentId;
  final int senderId;
  final UserRoom sender;
  final String message;
  final int? fileId;
  final List<dynamic> file;
  final dynamic poll;
  final dynamic voice;
  final dynamic private;
  final int roomId;
  final String room;
  final int adminId;
  final dynamic bot;
  final int unread;
  final List<dynamic> unreadRoom;
  final int edit;
  final dynamic forward;
  final dynamic forwarded;
  final UserRoom user;
  final dynamic mainMessage;
  final List<dynamic> reactions;
  final List<dynamic> replies;
  final List<dynamic> favoris;
  final int important;
  final dynamic tags;
  final int mobile;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;

  Message({
    required this.id,
    required this.type,
    this.parentId,
    required this.senderId,
    required this.sender,
    required this.message,
    this.fileId,
    required this.file,
    this.poll,
    this.voice,
    this.private,
    required this.roomId,
    required this.room,
    required this.adminId,
    this.bot,
    required this.unread,
    required this.unreadRoom,
    required this.edit,
    this.forward,
    this.forwarded,
    required this.user,
    this.mainMessage,
    required this.reactions,
    required this.replies,
    required this.favoris,
    required this.important,
    this.tags,
    required this.mobile,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      parentId: json['parent_id'],
      senderId: json['sender_id'] ?? 0,
      sender: UserRoom.fromJson(json['sender'] ?? {}),
      message: _stripHtmlTags(json['message']) ??
          "", // Utilisez la méthode pour supprimer les balises HTML
      fileId: json['file_id'],
      file: json['file'] ?? [],
      poll: json['poll'],
      voice: json['voice'],
      private: json['private'],
      roomId: json['room_id'] ?? 0,
      room: json['room'] ?? '',
      adminId: json['admin_id'] ?? 0,
      bot: json['bot'],
      unread: json['unread'] ?? 0,
      unreadRoom: json['unread_room'] ?? [],
      edit: json['edit'] ?? 0,
      forward: json['forward'],
      forwarded: json['forwarded'],
      user: UserRoom.fromJson(json['user'] ?? {}),
      mainMessage: json['main_message'],
      reactions: json['reactions'] ?? [],
      replies: json['replies'] ?? [],
      favoris: json['favoris'] ?? [],
      important: json['important'] ?? 0,
      tags: json['tags'],
      mobile: json['mobile'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'parent_id': parentId,
      'sender_id': senderId,
      'sender': sender.toJson(),
      'message': message,
      'file_id': fileId,
      'file': file,
      'poll': poll,
      'voice': voice,
      'private': private,
      'room_id': roomId,
      'room': room,
      'admin_id': adminId,
      'bot': bot,
      'unread': unread,
      'unread_room': unreadRoom,
      'edit': edit,
      'forward': forward,
      'forwarded': forwarded,
      'user': user.toJson(),
      'main_message': mainMessage,
      'reactions': reactions,
      'replies': replies,
      'favoris': favoris,
      'important': important,
      'tags': tags,
      'mobile': mobile,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  static String _stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }
}
