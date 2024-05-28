class TicketData {
  final String id;
  final String owner;
  final String list_of_customers;
  final String perimeters;
  final String pipeline;
  final String type_ticket;
  final String channel;
  final String subject;
  final String severity;
  final String folder;
  final String reference;
  final String sla;
  final String owner_avatar;
  final String label;
  final String created_at;
  final String room_id;
  final int pipeline_id;

  TicketData(
      {required this.id,
      required this.owner,
      required this.list_of_customers,
      required this.perimeters,
      required this.pipeline,
      required this.type_ticket,
      required this.channel,
      required this.subject,
      required this.severity,
      required this.folder,
      required this.reference,
      required this.sla,
      required this.owner_avatar,
      required this.label,
      required this.created_at,
      required this.room_id,
      required this.pipeline_id});

  factory TicketData.fromJson(Map<String, dynamic> json) => TicketData(
        id: json["id"],
        owner: json["owner"] ?? " ",
        list_of_customers: json["list_of_customers"] ?? "",
        perimeters: json["perimeters"] ?? "",
        pipeline: json["pipeline"] ?? "",
        type_ticket: json["type_ticket"] ?? "",
        channel: json["channel"] ?? "",
        subject: json["subject"] ?? "",
        severity: json["severity"] ?? "",
        folder: json["folder"] ?? "",
        reference: json["reference"] ?? "",
        sla: json["sla"] ?? "",
        owner_avatar: json["owner_avatar"] ?? "",
        label: json["label"] ?? "",
        created_at: json["created_at"] ?? "",
        room_id: "${json['room_id']}" ?? '',
        pipeline_id: json["pipeline_id"] ?? 0,
      );
}
