import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/ticket/Ticket.dart';
import 'package:flutter_application_stage_project/screens/detailElment.dart';
import '../core/constants/shared/config.dart';
import '../models/ticket/ticketData.dart';
import '../services/search/ApiTicketList.dart';

class CustomSearchDelegate extends SearchDelegate {
  final String idFamily;
  final ApiTicketList _ticketList = ApiTicketList();
  int _page = 1; // Numéro de page initial
  int _pageSize = 10; // Taille de la page
  List<TicketData> _suggestions = [];
  bool _isLoadingMore = false; // Indicateur de chargement
  final StreamController<List<TicketData>> _suggestionsController =
      StreamController<List<TicketData>>.broadcast(); // Changed to broadcast
  Timer? _debounce; // Timer pour la recherche différée

  CustomSearchDelegate({required this.idFamily}) {
    _fetchInitialSuggestions();
  }

  @override
  String? get searchFieldLabel => _getSearchLabel();

  String _getSearchLabel() {
    switch (idFamily) {
      case '6':
        return 'Search ticket';
      case '3':
        return 'Search deal';
      case '7':
        return 'Search project';
      default:
        return 'Search';
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          _suggestions.clear();
          _suggestionsController.add(_suggestions);
        },
        icon: Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<TicketData>>(
      future: _ticketList.getTicketList(query: query, idFamily: idFamily),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
          );
        }
        List<TicketData>? data = snapshot.data;
        return ListView.builder(
          itemCount: data?.length,
          itemBuilder: (context, index) {
            return _buildListTile(context, data![index]);
          },
        );
      },
    );
  }

  Future<void> _fetchInitialSuggestions() async {
    final initialSuggestions = await _fetchSuggestions();
    _suggestions = initialSuggestions;
    _suggestionsController.add(_suggestions);
  }

  Future<List<TicketData>> _fetchSuggestions() async {
    final response = await _ticketList.getTicketList(
        query: query, idFamily: idFamily, page: _page, pageSize: _pageSize);
    return response;
  }

  void _loadMoreSuggestions() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;
    _page++;
    final newData = await _fetchSuggestions();
    if (newData.isNotEmpty) {
      _suggestions.addAll(newData);
      _suggestionsController.add(_suggestions);
    }
    _isLoadingMore = false;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchInitialSuggestions();
    });

    return StreamBuilder<List<TicketData>>(
      stream: _suggestionsController.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No suggestions available.'));
        }

        _suggestions = snapshot.data!;

        return _buildSuggestionsList(context, _suggestions);
      },
    );
  }

  Widget _buildSuggestionsList(
      BuildContext context, List<TicketData> suggestions) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (!_isLoadingMore &&
            notification is ScrollEndNotification &&
            notification.metrics.pixels ==
                notification.metrics.maxScrollExtent) {
          _loadMoreSuggestions();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return _buildListTile(context, suggestions[index]);
        },
      ),
    );
  }

  Widget _buildListTile(BuildContext context, TicketData ticket) {
    return ListTile(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return DetailElment(
              idElment: '${ticket.id}',
              idFamily: idFamily,
              roomId: '${ticket.room_id}',
              label: '${ticket.label}',
              refenrce: '${ticket.reference}',
              pipeline_id: ticket.pipeline_id,
            );
          },
        ));
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(ticket.reference),
          Text(
            ticket.created_at,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ticket.type_ticket),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ticket.owner,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              FutureBuilder<String>(
                future: Config.getApiUrl("urlImage"),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ticket.owner_avatar.length == 1
                        ? CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              ticket.owner_avatar,
                              style: TextStyle(color: Colors.white),
                            ),
                            radius: 15,
                          )
                        : CircleAvatar(
                            backgroundImage: NetworkImage(
                                "${snapshot.data}${ticket.owner_avatar}"),
                            radius: 15,
                          );
                  } else {
                    return CircleAvatar(
                      child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                      radius: 15,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _suggestionsController.close();
    //super.dispose();
  }
}
