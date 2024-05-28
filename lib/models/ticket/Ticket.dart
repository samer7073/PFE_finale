import 'package:flutter_application_stage_project/models/ticket/ticketData.dart';

class Ticket {
  //final bool success;
  final List<TicketData> data;
  Ticket({ required this.data});
  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      //success: json['success'],
      data: (json['data'] as List)
          .map((ticketJson) => TicketData.fromJson(ticketJson))
          .toList(),
    );
  }
}
