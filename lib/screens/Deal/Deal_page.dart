// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/homeNavigate_page.dart';

import '../CustomSearchDelegate.dart';
import '../NotficationPage.dart';
import '../PipelineScreen.dart';

import '../ticket/addTicket.dart';
import 'DealList.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DealPage extends StatefulWidget {
  const DealPage({super.key});

  @override
  State<DealPage> createState() => _DealPageState();
}

class _DealPageState extends State<DealPage> {
  int _selectedIndex = 0;
  String _viewMode = 'List view';

  static List<Widget> _widgetOptions = <Widget>[
    DealsPage(),
    PipelineScreen(idFamily: "3"),
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
    int newIndex = ['List view', 'Kanban '].indexOf(viewMode);
    _onItemTapped(newIndex);
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
                      family_id: "3",
                      titel: "Deal",
                    )),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
         leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushAndRemoveUntil<dynamic>(
              context,
              MaterialPageRoute<dynamic>(
                builder: (BuildContext context) => HomeNavigate(
                  id_page: 0,
                ),
              ),
              (route) => false,
            );
          },
        ),
        title: Text(AppLocalizations.of(context)!.deals),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(idFamily: "3"));
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
              return ['List view', 'Kanban ']
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
