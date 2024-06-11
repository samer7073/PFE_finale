// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/project/ProjectList.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';
import '../CustomSearchDelegate.dart';
import '../NotficationPage.dart';
import '../PipelineScreen.dart';
import '../notifications/notifications_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late ThemeProvider themeProvider;
  void initState() {
    // TODO: implement initState
    super.initState();
    log("test Init state activted ");
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    log("valeur isdark  dans initstate ${themeProvider.isDarkMode}");
  }

  int _selectedIndex = 0;
  String _viewMode = 'List view';

  static List<Widget> _widgetOptions = <Widget>[
    ProjectList(),
    PipelineScreen(idFamily: "7"),
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).projects),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchDelegate("7"));
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
