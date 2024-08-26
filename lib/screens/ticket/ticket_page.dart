// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';

import 'package:flutter_application_stage_project/screens/PipelineScreen.dart';
import 'package:flutter_application_stage_project/screens/ticket/addTicket.dart';
import 'package:flutter_application_stage_project/screens/ticket/ticket_list.dart';
import 'package:provider/provider.dart';

import '../CustomSearchDelegate.dart';
import '../NotficationPage.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({Key? key}) : super(key: key);

  @override
  State<TicketPage> createState() => _TicketState();
}

class _TicketState extends State<TicketPage> {
  late ThemeProvider themeProvider;
  late String _viewMode;

  @override
  void initState() {
    super.initState();
    log("test Init state activated");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    log("valeur isdark dans initstate ${themeProvider.isDarkMode}");
    _viewMode = AppLocalizations.of(context)!.listView;
  }

  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    TicketList(),
    PipelineScreen(idFamily: "6"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _changeViewMode(String viewMode) {
    setState(() {
      _viewMode = viewMode;
    });
    int newIndex = [
      AppLocalizations.of(context)!.listView,
      AppLocalizations.of(context)!.kanban
    ].indexOf(viewMode);
    _onItemTapped(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddElement(
                family_id: "6",
                titel: "Ticket",
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.tickets),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(idFamily: "6"));
            },
            icon: Icon(
              Icons.search,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return NotificationPage();
                },
              ));
            },
            icon: Icon(
              Icons.notifications_none_sharp,
              size: 30,
            ),
          ),
          PopupMenuButton(
            initialValue: _viewMode,
            onSelected: _changeViewMode,
            itemBuilder: (BuildContext context) {
              return [
                AppLocalizations.of(context)!.listView,
                AppLocalizations.of(context)!.kanban
              ]
                  .map((mode) => PopupMenuItem(
                        value: mode,
                        child: Text(mode),
                      ))
                  .toList();
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}
