import 'dart:convert';

// Modèle Deal
class Deal {
  final String id;
  final String owner;
  final String ownerAvatar;
  final int stageId;
  final String createdAt;
  final String label;
  final String stagePipeline;
  final String organisation;
  final String source;
  final String status;
  final String reference;
  final String room_id;
  final int pipeline_id;

  Deal({
    required this.id,
    required this.owner,
    required this.ownerAvatar,
    required this.stageId,
    required this.createdAt,
    required this.label,
    required this.stagePipeline,
    required this.organisation,
    required this.source,
    required this.status,
    required this.reference,
    required this.room_id,
    required this.pipeline_id,
  });

  // Factory method to create a Deal from JSON
  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'] ?? '',
      owner: json['owner'] ?? '',
      ownerAvatar: json['owner_avatar'] ?? '',
      stageId: json['stage_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      label: json['label'] ?? '',
      stagePipeline: json['stage_pipeline'] ?? '',
      organisation: json['organisation'] ?? '',
      source: json['source'] ?? '',
      status: json['status'] ?? '',
      reference: json['reference'] ?? '',
      room_id: "${json['room_id']}" ?? '',
      pipeline_id: json['pipeline_id'] ?? 0,
    );
  }

  // Method to convert a Deal to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner': owner,
      'owner_avatar': ownerAvatar,
      'stage_id': stageId,
      'created_at': createdAt,
      'label': label,
      'stage_pipeline': stagePipeline,
      'organisation': organisation,
      'source': source,
      'status': status,
      'reference': reference,
    };
  }
}

// Fonction pour convertir la réponse JSON en liste de Deals
List<Deal> parseDeals(String responseBody) {
  final parsed = json.decode(responseBody);
  return (parsed['data'] as List)
      .map<Deal>((json) => Deal.fromJson(json))
      .toList();
}
