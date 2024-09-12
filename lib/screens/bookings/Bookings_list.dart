import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/bookings_models/BookingsApiRespose.dart';
import 'package:flutter_application_stage_project/models/bookings_models/bookingsData.dart';
import 'package:flutter_application_stage_project/screens/bookings/BookingListRow.dart';

import 'package:flutter_application_stage_project/services/bookingsService/BookingsService.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

import '../../services/ApiDeleteElment.dart';

import '../EditElment.dart';
import '../detailElment.dart';


class BookingsList extends StatefulWidget {
  const BookingsList({Key? key}) : super(key: key);

  @override
  State<BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<BookingsList> {
  List<Bookingsdata> bookings = [];
  bool isLoading = false;
  int page = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchBookings();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchMoreTickets();
      }
    });
  }

  Future<void> fetchBookings() async {
    setState(() {
      isLoading = true;
    });

    try {
      BookingsApiResponse Bookings = await Bookingsservice.getAllBookings(page: page);
      setState(() {
        bookings.addAll(Bookings.data);
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
      fetchBookings();
    }
  }

  void deleteTicket(Bookingsdata ticket) async {
    setState(() {
      bookings.removeWhere((element) => element.id == ticket.id);
    });

    try {
      final delteResponse =
          await ApiDeleteElement.deleteElement({"ids[]": ticket.id});
      if (delteResponse == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            action: SnackBarAction(label: "Ok", onPressed: () {}),
            content: Text('Item successfully deleted!',style: TextStyle(color: Colors.white),),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: Item not deleted",style: TextStyle(color: Colors.white),)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Item not deleted",style: TextStyle(color: Colors.white),)),
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
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Slidable(
                  endActionPane: ActionPane(motion: DrawerMotion(), children: [
                    SlidableAction(
                      icon: Icons.delete,
                      foregroundColor: Colors.red,
                      
                      backgroundColor: Colors.transparent,
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
                                    deleteTicket(booking);
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
                              Element_id: booking.id,
                              family_id: "8",
                              title: "Bookings",
                            ),
                          ),
                        );
                      },
                      icon: Icons.edit,
                      foregroundColor: Colors.green,
                      backgroundColor: Colors.transparent,
                    )
                  ]),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return DetailElment(
                            idElment: booking.id,
                            idFamily: "6",
                            roomId: booking.id!,
                            label: booking.label,
                            refenrce: booking.reference,
                            pipeline_id: booking.pipelineId,
                          );
                        },
                      ));
                    },
                    child: BookingsListRow(
                      Pipeline: booking.Pipeline,
                      SourceIcon: Icons.abc,
                      id: booking.reference,
                      title: booking.label,
                      owner: booking.owner,
                      createTime: booking.createdAt,
                     
                      ownerImage: booking.ownerAvatar,
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLoading) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
            ),
          ],
        ],
      ),
    );
  }
}