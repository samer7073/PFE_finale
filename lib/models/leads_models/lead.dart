class Lead {
  final String id;
  final String owner;
  final String ownerAvatar;
  final int stageId;
  final String createdAt;
  final String roomId;
  final String fullName;
  final String source;
  final String pipeline;
  final int pipelineId;
  final String email;
  final List<String> partagerAvec;
  final String reference;
  final String conversation_id;
  final String avatar;
  final String seen_by;
  final String updated_at;
  final String date_last_message;
  final String last_message;
  
  Lead({
    required this.id,
    required this.owner,
    required this.ownerAvatar,
    required this.stageId,
    required this.createdAt,
    required this.roomId,
    required this.fullName,
    required this.source,
    required this.pipeline,
    required this.pipelineId,
    required this.email,
    required this.partagerAvec,
    required this.reference,
    required this.conversation_id,
    required this.avatar,
    required this.seen_by,
    required this.updated_at,
    required this.date_last_message,
    required this.last_message

  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] ?? '',
      owner: json['owner'] ?? '',
      ownerAvatar: json['owner_avatar'] ?? '',
      stageId: json['stage_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      roomId: json['room_id'] ?? "",
      fullName: json['full_name'] ?? '',
      source: json['source'] ?? '',
      pipeline: json['pipeline'] ?? '',
      pipelineId: json['pipeline_id'] ?? 0,
      email: json['email'] ?? '',
      partagerAvec: List<String>.from(json['partager_avec'] ?? []),
      reference: json['reference'] ?? '',
      conversation_id: json['conversation_id'] ?? '',
      avatar:json['avatar'] ?? '',
      seen_by: json['seen_by'] ?? '',
      updated_at:json['updated_at'] ?? '',
      date_last_message:json['date_last_message'] ?? '',
      last_message:json['last_message']?? '',
      
    );
  }
}