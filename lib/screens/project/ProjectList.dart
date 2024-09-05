// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
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
      Ticket ticketResponse = await GetTicketApi.getAllTickets("7", page: page);

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
      final deleteResponse =
          await ApiDeleteElement.deleteElement({"ids[]": ticket.id});
      if (deleteResponse == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            action: SnackBarAction(label: "Ok", onPressed: () {}),
            content: Text('Element supprimer avec succès !',style: TextStyle(color: Colors.white),),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : Element non supprimé",style: TextStyle(color: Colors.white),)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : Element non supprimé",style: TextStyle(color: Colors.white),)),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddElement(
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: tickets.length,
              itemBuilder: (context, index) {
                final project = tickets[index];
                return Slidable(
                  endActionPane: ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      icon: Icons.delete,
                     foregroundColor: Colors.red,
                      backgroundColor: Colors.transparent,
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue, // Définit la couleur de fond en bleu
                                    ),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                    deleteTicket(project);
                                  },
                                  child: Text("Yes"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Définit la couleur de fond en bleu
            ),
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
                      foregroundColor: Colors.green,
                      backgroundColor: Colors.transparent,
                    )
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return DetailElment(
                              idElment: project.id,
                              idFamily: "7",
                              roomId: project.room_id!,
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
                        ownerImage: project.owner_avatar,
                        pipline: project.pipeline,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
            ),
        ],
      ),
    );
  }
}
