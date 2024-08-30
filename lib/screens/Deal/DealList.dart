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
  bool isLoadingMore = false;
  bool hasMore = true;
  int page = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchDeals();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (hasMore && !isLoadingMore) {
        fetchMoreDeals();
      }
    }
  }

  Future<void> fetchDeals() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Deal> fetchedDeals = await ApiDeal.getAllDeals('3', page: page);
      setState(() {
        deals =
            fetchedDeals; // Remplacez les deals actuels par les deals récupérés
        isLoading = false;
        hasMore = fetchedDeals.length == 10; // Taille de la page est 10
      });
    } catch (error) {
      log('Error fetching deals: $error');
      setState(() {
        isLoading = false;
        hasMore = false;
      });
    }
  }

  Future<void> fetchMoreDeals() async {
    if (isLoading || isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    // Sauvegardez la position actuelle du défilement
    double currentPosition = _scrollController.position.pixels;

    try {
      page++;
      List<Deal> fetchedDeals = await ApiDeal.getAllDeals('3', page: page);
      setState(() {
        deals.addAll(fetchedDeals);
        isLoadingMore = false;
        hasMore = fetchedDeals.length == 10; // Taille de la page est 10
      });

      // Restaurez la position du défilement après ajout de nouveaux éléments
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(currentPosition);
      });
    } catch (error) {
      log('Error fetching more deals: $error');
      setState(() {
        isLoadingMore = false;
        hasMore = false;
      });
    }
  }

  void deleteElement(Deal deal) async {
    setState(() {
      deals.removeWhere((element) => element.id == deal.id);
    });

    try {
      final deleteResponse =
          await ApiDeleteElement.deleteElement({"ids[]": deal.id});
      if (deleteResponse == 200) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            action: SnackBarAction(label: "Ok", onPressed: () {}),
            content: Text('Element supprimé avec succès !'),
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification &&
                    _scrollController.position.extentAfter == 0 &&
                    hasMore &&
                    !isLoadingMore) {
                  fetchMoreDeals();
                }
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: deals.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < deals.length) {
                    final deal = deals[index];
                    return Slidable(
                      endActionPane:
                          ActionPane(motion: DrawerMotion(), children: [
                        SlidableAction(
                          icon: Icons.delete,
                         foregroundColor: Colors.red,
                      backgroundColor: Colors.transparent,
                          onPressed: (context) {
                            log("delete");
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Delete"),
                                  content: Text(
                                      "Are you sure you want to delete this deal?"),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue, // Définit la couleur de fond en bleu
  ),
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                        deleteElement(deal);
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
                                  Element_id: deal.id,
                                  family_id: "3",
                                  title: "Deal",
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
                          child: DealListRow(
                            reference: deal.reference,
                            title: deal.label,
                            owner: deal.owner,
                            ownerImage: deal.ownerAvatar,
                            createTime: deal.createdAt,
                            organisation: deal.organisation,
                            piepline: deal.stagePipeline,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink(); // Retourne un widget vide
                  }
                },
              ),
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
