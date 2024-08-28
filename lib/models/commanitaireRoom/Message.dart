class Message {
  final String id;
  final String type;
  final String? parentId;
  final String senderUuid;
  final String senderId;
  final String message;
  final String? fileId;
  final List<dynamic> file;
  final dynamic poll;
  final dynamic voice;
  final dynamic bot;
  final int private;
  final String roomId;
  final int unread;
  final List<dynamic> unreadRoom;
  final int edit;
  final dynamic forward;
  final dynamic forwarded;
  final dynamic mainMessage;
  final List<dynamic> reactions;
  final List<dynamic> replies;
  final dynamic favoris;
  final String? important;
  final dynamic tags;
  final dynamic code;
  final dynamic voiceSize;
  final int mobile;
  final String createdAt;
  final String updatedAt;
  final dynamic deletedAt;

  Message({
    required this.id,
    required this.type,
    this.parentId,
    required this.senderUuid,
    required this.senderId,
    required this.message,
    this.fileId,
    required this.file,
    this.poll,
    this.voice,
    this.bot,
    required this.private,
    required this.roomId,
    required this.unread,
    required this.unreadRoom,
    required this.edit,
    this.forward,
    this.forwarded,
    this.mainMessage,
    required this.reactions,
    required this.replies,
    this.favoris,
    this.important,
    this.tags,
    this.code,
    this.voiceSize,
    required this.mobile,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      parentId: json['parent_id'],
      senderUuid: json['sender_uuid'] ?? '',
      senderId: json['sender_id'] ?? '',
      message: _stripHtmlTags(json['message']) ??
          "", // Utilisez la méthode pour supprimer les balises HTML
      fileId: json['file_id'],
      file: json['file'] as List<dynamic>? ?? [],
      poll: json['poll'],
      voice: json['voice'],
      bot: json['bot'],
      private: json['private'] ?? 0,
      roomId: json['room_id'] ?? '',
      unread: json['unread'] ?? 0,
      unreadRoom: json['unread_room'] as List<dynamic>? ?? [],
      edit: json['edit'] ?? 0,
      forward: json['forward'],
      forwarded: json['forwarded'],
      mainMessage: json['main_message'],
      reactions: json['reactions'] as List<dynamic>? ?? [],
      replies: json['replies'] as List<dynamic>? ?? [],
      favoris: json['favoris'],
      important: json['important'],
      tags: json['tags'],
      code: json['code'],
      voiceSize: json['voice_size'],
      mobile: json['mobile'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }

  static String _stripHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }
}
