import 'package:flutter/material.dart';
import '../core/constants/shared/config.dart';
import '../models/ticket/ticketData.dart';
import '../services/search/ApiTicketList.dart';
import 'detailElment.dart';

class CustomSearchDelegate extends SearchDelegate {
  final String idFamily;
  final ApiTicketList _ticketList = ApiTicketList();

  CustomSearchDelegate(this.idFamily);

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
            return InkWell(
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
                        FutureBuilder<String>(
                          future: Config.getApiUrl("urlImage"),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return CircleAvatar(
                                backgroundImage: NetworkImage(
                                  "${snapshot.data}${data?[index].owner_avatar}",
                                ),
                                radius: 15,
                              );
                            } else {
                              return CircleAvatar(
                                child: CircularProgressIndicator(),
                                radius: 15,
                              );
                            }
                          },
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
                      FutureBuilder<String>(
                        future: Config.getApiUrl("urlImage"),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return CircleAvatar(
                              backgroundImage: NetworkImage(
                                "${snapshot.data}${data?[index].owner_avatar}",
                              ),
                              radius: 15,
                            );
                          } else {
                            return CircleAvatar(
                              child: CircularProgressIndicator(),
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
          },
        );
      },
    );
  }
}
