// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../models/Deal/DealModel.dart';
import '../../services/ApiDeleteElment.dart';
import '../../services/deal/ApiDeal.dart';
import '../EditElment.dart';
import '../detailElment.dart';
import 'DealListRow.dart';

class DealsPage extends StatefulWidget {
  @override
  _DealsPageState createState() => _DealsPageState();
}

class _DealsPageState extends State<DealsPage> {
  List<Deal> deals = [];
  bool isLoading = false;
  int page = 1;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchDeals();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchMoreDeals();
      }
    });
  }

  Future<void> fetchDeals() async {
    setState(() {
      isLoading = true;
    });

    List<Deal> fetchedDeals = await ApiDeal.getAllDeals('3', page: page);
    setState(() {
      deals.addAll(fetchedDeals);
      isLoading = false;
    });
  }

  Future<void> fetchMoreDeals() async {
    if (!isLoading) {
      page++;
      fetchDeals();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void deleteElment(Deal deal) async {
    setState(() {
      deals.removeWhere((element) => element.id == deal.id);
    });

    try {
      final delteResponse =
          await ApiDeleteElment.DeleteElment({"ids[]": deal.id});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: deals.length,
              itemBuilder: (context, index) {
                final deal = deals[index];
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
                                    deleteElment(deal);
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
                              Element_id: deal.id,
                              family_id: "3",
                              title: "Deal",
                            ),
                          ),
                        );
                      },
                      icon: Icons.edit,
                      backgroundColor: Colors.green,
                    )
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return DetailElment(
                              idElment: deal.id,
                              idFamily: "3",
                              roomId: deal.room_id,
                              label: deal.label,
                              refenrce: deal.reference,
                              pipeline_id: deal.pipeline_id,
                            );
                          },
                        ));
                      },
                      child: Column(
                        children: [
                          DealListRow(
                            reference: deal.reference,
                            title: deal.label,
                            owner: deal.owner,
                            ownerImage: deal.ownerAvatar,
                            createTime: deal.createdAt,
                            organisation: deal.organisation,
                            piepline: deal.stagePipeline,
                          ),
                        ],
                      ),
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
