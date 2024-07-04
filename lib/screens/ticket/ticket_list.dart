// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'package:flutter_application_stage_project/screens/EditElment.dart';
import 'package:flutter_application_stage_project/screens/detailElment.dart';
import 'package:flutter_application_stage_project/services/ApiDeleteElment.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/ticket/ticketListRow.dart';

import '../../models/ticket/ticket.dart';
import '../../models/ticket/ticketData.dart';
import '../../services/tickets/getTicketApi.dart';

class TicketList extends StatefulWidget {
  const TicketList({Key? key}) : super(key: key);

  @override
  State<TicketList> createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  List<TicketData> tickets = [];

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Map<String, dynamic> fieldValues = {};

  Future<void> fetchTickets() async {
    try {
      Ticket ticketResponse = await GetTicketApi.getAllTickets("6");

      setState(() {
        tickets = ticketResponse.data;
        loading = false;
      });
    } catch (e) {
      print('Failed to fetch tickets: $e');
    }
  }

  void deleteTicket(TicketData ticket) async {
    setState(() {
      tickets.removeWhere((element) => element.id == ticket.id);
    });

    try {
      final delteResponse =
          await ApiDeleteElement.deleteElement({"ids[]": ticket.id});
      if (delteResponse == 200) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            action: SnackBarAction(label: "Ok", onPressed: () {}),
            content: Text('Item successfully deleted!'),
          ),
        );
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Item not deleted")),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Item not deleted")),
      );
    }
  }

  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : Container(
            height:
                MediaQuery.of(context).size.height * 0.8, // Limite la hauteur
            child: ListView.builder(
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Slidable(
                  endActionPane: ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      icon: Icons.delete,
                      backgroundColor: Colors.red,
                      onPressed: (context) {
                        log("hello");
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Delete"),
                              content: Text(
                                  "Are you sure you want to delete this ticket ?"),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    // User confirmed deletion
                                    deleteTicket(ticket);
                                  },
                                  child: Text("Yes"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false); // User cancelled deletion
                                  },
                                  child: Text("No"),
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        log("edit");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditElment(
                              Element_id: ticket.id,
                              family_id: "6",
                              title: "Ticket",
                            ),
                          ),
                        );
                      },
                      icon: Icons.edit,
                      backgroundColor: Colors.green,
                    )
                  ]),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return DetailElment(
                            idElment: ticket.id,
                            idFamily: "6",
                            roomId: ticket.room_id!,
                            label: ticket.label,
                            refenrce: ticket.reference,
                            pipeline_id: ticket.pipeline_id,
                          );
                        },
                      ));
                    },
                    child: ticketListRow(
                      Pipeline: ticket.pipeline,
                      SourceIcon: Icons.abc,
                      id: ticket.reference,
                      title: ticket.type_ticket,
                      owner: ticket.owner,
                      createTime: ticket.created_at,
                      stateIcon: Icons.abc,
                      stateMessage: "Open",
                      colorContainer: ticket.severity == "High"
                          ? Colors.red
                          : ticket.severity == "Medium"
                              ? Colors.amber
                              : ticket.severity == "Normal"
                                  ? Colors.green
                                  : ticket.severity == "Low"
                                      ? Colors.blue
                                      : Colors.blue,
                      messageContainer: ticket.severity,
                      ownerImage: ticket.owner_avatar,
                    ),
                  ),
                );
              },
            ),
          );
  }
}
