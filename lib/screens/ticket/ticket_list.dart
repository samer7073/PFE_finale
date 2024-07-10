import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/ticket/ticket.dart';
import '../../models/ticket/ticketData.dart';
import '../../services/ApiDeleteElment.dart';
import '../../services/tickets/getTicketApi.dart';
import '../EditElment.dart';
import '../detailElment.dart';
import 'ticketListRow.dart';

class TicketList extends StatefulWidget {
  const TicketList({Key? key}) : super(key: key);

  @override
  State<TicketList> createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  List<TicketData> tickets = [];
  bool isLoading = false;
  int page = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchTickets();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchMoreTickets();
      }
    });
  }

  Future<void> fetchTickets() async {
    setState(() {
      isLoading = true;
    });

    try {
      Ticket ticketResponse = await GetTicketApi.getAllTickets("6", page: page);
      setState(() {
        tickets.addAll(ticketResponse.data);
        isLoading = false;
      });
    } catch (e) {
      print('Failed to fetch tickets: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMoreTickets() async {
    if (!isLoading) {
      page++;
      fetchTickets();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            action: SnackBarAction(label: "Ok", onPressed: () {}),
            content: Text('Item successfully deleted!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Item not deleted")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Item not deleted")),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return Slidable(
                  endActionPane: ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      icon: Icons.delete,
                      backgroundColor: Colors.red,
                      onPressed: (context) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Delete"),
                              content: Text(
                                  "Are you sure you want to delete this ticket?"),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    deleteTicket(ticket);
                                  },
                                  child: Text("Yes"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
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
          ),
          if (isLoading) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          ],
        ],
      ),
    );
  }
}
