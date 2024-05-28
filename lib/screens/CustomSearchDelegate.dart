import 'package:flutter/material.dart';
import '../models/ticket/ticketData.dart';
import '../services/search/ApiTicketList.dart';
import 'detailElment.dart';

class CustomSearchDelegate extends SearchDelegate {
  final String idFamily;

  // Constructor with the additional string parameter
  CustomSearchDelegate(this.idFamily);

  final ApiTicketList _ticketList = ApiTicketList();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
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
            child: CircularProgressIndicator(),
          );
        }
        List<TicketData>? data = snapshot.data;
        return ListView.builder(
          itemCount: data?.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return DetailElment(
                      idElment: '${data?[index].id}',
                      idFamily: idFamily,
                      roomId: '${data?[index].room_id}',
                      label: '${data?[index].label}',
                      refenrce: '${data?[index].reference}',
                      pipeline_id: data![index].pipeline_id,
                    );
                  },
                ));
              },
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${data?[index].reference}'),
                    Text(
                      '${data?[index].created_at}',
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${data?[index].type_ticket}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${data?[index].owner}',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        data?[index].owner_avatar.length == 1
                            ? CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  '${data?[index].owner_avatar}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                radius: 15,
                              )
                            : CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "https://spherebackdev.cmk.biz:4543/storage/uploads/${data?[index].owner_avatar}",
                                ),
                                radius: 15,
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Display suggestions based on the current query
    return FutureBuilder<List<TicketData>>(
      future: _ticketList.getTicketList(query: query, idFamily: idFamily),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('No suggestions available.'),
          );
        }
        List<TicketData>? data = snapshot.data;
        return ListView.builder(
          itemCount: data?.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                query = '${data?[index].reference}';
                showResults(context);
              },
              title: Text('${data?[index].reference}'),
              subtitle: Text('${data?[index].type_ticket}'),
            );
          },
        );
      },
    );
  }
}
