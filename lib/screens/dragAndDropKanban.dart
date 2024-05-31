import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:drag_and_drop_lists/drag_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/ticket/ticketListRow.dart';
import 'package:provider/provider.dart';

import '../../models/ticket/ticket.dart';
import '../../models/ticket/ticketData.dart';
import '../../services/tickets/getTicketApi.dart';
import '../providers/theme_provider.dart';

class DragAndDropKanban extends StatefulWidget {
  @override
  _DragAndDropKanban createState() => _DragAndDropKanban();
}

class _DragAndDropKanban extends State<DragAndDropKanban> {
  late List<DragAndDropList> lists = [];
  late ThemeProvider themeProvider;
  List<TicketData> tickets = [];

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      Ticket ticketResponse = await GetTicketApi.getAllTickets("6");
      setState(() {
        tickets = ticketResponse.data;
        lists = buildListsFromTickets(tickets);
      });
    } catch (e) {
      print('Failed to fetch tickets: $e');
    }
  }

  List<DragAndDropList> buildListsFromTickets(List<TicketData> data) {
    return data.map((ticket) {
      return DragAndDropList(
        header: Container(
          padding: EdgeInsets.all(8),
          child: Text(
            ticket.folder,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        children: [
          DragAndDropItem(
              child: ticketListRow(
                  Pipeline: ticket.pipeline,
                  SourceIcon: Icons.abc,
                  id: ticket.reference,
                  title: ticket.type_ticket,
                  owner: ticket.owner,
                  createTime: ticket.sla,
                  stateIcon: Icons.abc_outlined,
                  stateMessage: "open",
                  colorContainer: ticket.severity == "Heigh"
                      ? Colors.red
                      : ticket.severity == "Normal"
                          ? Colors.amber
                          : Colors.green,
                  messageContainer: ticket.severity,
                  ownerImage: ticket.owner_avatar)),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color.fromARGB(255, 243, 242, 248);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: DragAndDropLists(
        lastItemTargetHeight: 25,
        addLastItemTargetHeightToTop: true,
        lastListTargetSize: 30,
        listPadding: EdgeInsets.all(16),
        listInnerDecoration: BoxDecoration(
          color: theme.canvasColor,
          borderRadius: BorderRadius.circular(10),
        ),
        children: lists,
        itemDivider: Divider(thickness: 2, height: 2, color: backgroundColor),
        itemDecorationWhileDragging: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        listDragHandle: buildDragHandle(isList: true),
        itemDragHandle: buildDragHandle(),
        onItemReorder: onReorderListItem,
        onListReorder: onReorderList,
      ),
    );
  }

  DragHandle buildDragHandle({bool isList = false}) {
    final verticalAlignment = isList
        ? DragHandleVerticalAlignment.top
        : DragHandleVerticalAlignment.center;
    final color = isList ? Colors.blueGrey : Colors.black26;

    return DragHandle(
      verticalAlignment: verticalAlignment,
      child: Container(
        padding: EdgeInsets.only(right: 10),
        child: Icon(Icons.menu, color: color),
      ),
    );
  }

  void onReorderListItem(
    int oldItemIndex,
    int oldListIndex,
    int newItemIndex,
    int newListIndex,
  ) {
    setState(() {
      final oldListItems = lists[oldListIndex].children;
      final newListItems = lists[newListIndex].children;

      final movedItem = oldListItems.removeAt(oldItemIndex);
      newListItems.insert(newItemIndex, movedItem);
    });
  }

  void onReorderList(
    int oldListIndex,
    int newListIndex,
  ) {
    setState(() {
      final movedList = lists.removeAt(oldListIndex);
      lists.insert(newListIndex, movedList);
    });
  }
}
