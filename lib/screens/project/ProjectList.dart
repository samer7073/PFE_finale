import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter_application_stage_project/screens/project/project_list_row.dart';
import 'package:flutter_application_stage_project/screens/ticket/addTicket.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/ticket/ticket.dart';
import '../../../models/ticket/ticketData.dart';

import 'package:flutter_application_stage_project/services/tickets/getTicketApi.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../services/ApiDeleteElment.dart';
import '../EditElment.dart';
import '../detailElment.dart';
import '../loading.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({super.key});

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  List<TicketData> tickets = [];

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Map<String, dynamic> fieldValues = {};

  Future<void> fetchTickets() async {
    try {
      Ticket ticketResponse = await GetTicketApi.getAllTickets("7");

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
          await ApiDeleteElment.DeleteElment({"ids[]": ticket.id});
      if (delteResponse == 200) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            action: SnackBarAction(label: "Ok", onPressed: () {}),
            content: Text('Element supprimer avec succès !'),
          ),
        );
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : Element non supprimé")),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : Element non supprimé")),
      );
    }
  }

  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTicket(
                            family_id: "7",
                            titel: "Project",
                          )),
                );
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            body: Container(
              height:
                  MediaQuery.of(context).size.height * 0.8, // Limite la hauteur
              child: ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final project = tickets[index];
                  return Slidable(
                    endActionPane:
                        ActionPane(motion: DrawerMotion(), children: [
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
                                      deleteTicket(project);
                                    },
                                    child: Text("Yes"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          false); // User cancelled deletion
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
                                Element_id: project.id,
                                family_id: "7",
                                title: "Project",
                              ),
                            ),
                          );
                        },
                        icon: Icons.edit,
                        backgroundColor: Colors.green,
                      )
                    ]),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return DetailElment(
                                idElment: project.id,
                                idFamily: "7",
                                roomId: project.room_id,
                                label: project.label,
                                refenrce: project.reference,
                                pipeline_id: project.pipeline_id,
                              );
                            },
                          ));
                        },
                        child: ProjectListRow(
                            createTime: project.created_at,
                            reference: project.reference,
                            title: project.label,
                            owner: project.owner,
                            ownerImage: project.owner_avatar),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }
}
