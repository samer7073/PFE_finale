// ignore_for_file: use_build_context_synchronously, prefer_final_fields

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/project/ProjectList.dart';
import 'package:flutter_application_stage_project/screens/ticket/addTicket.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../CustomSearchDelegate.dart';
import '../NotficationPage.dart';
import '../PipelineScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late ThemeProvider themeProvider;
  late List<Widget> _widgetOptions;
  final GlobalKey<ProjectListState> projectListKey = GlobalKey();
  final GlobalKey<PipelineScreenState> projectKanbanKey = GlobalKey();
  void initState() {
    // TODO: implement initState
    super.initState();
    log("test Init state activted ");
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    log("valeur isdark  dans initstate ${themeProvider.isDarkMode}");
    _widgetOptions = <Widget>[
      ProjectList(
        key: projectListKey,
      ),
      PipelineScreen(idFamily: "7",key: projectKanbanKey,),
    ];
  }

  int _selectedIndex = 0;
  String _viewMode = 'List view';

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

  Future<void> _addproject() async {
    final addproject = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddElement(
                family_id: "7",
                titel: AppLocalizations.of(context)!.project,
              )),
    );

    if (addproject == true) {
      // Rafraîchir la vue active en fonction de l'index sélectionné
      if (_selectedIndex == 0) {
        projectListKey.currentState
            ?.fetchTickets(); // Rafraîchit la liste des tickets
      } else if (_selectedIndex == 1) {
        projectKanbanKey.currentState
            ?.initializeFirstStage(); // Rafraîchit la vue kanban
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          _addproject();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.projects),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(idFamily: "7"));
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
            onSelected: (String viewMode) {
              setState(() {
                _viewMode = viewMode;
              });
              int newIndex = [
                AppLocalizations.of(context)!.listView,
                AppLocalizations.of(context)!.kanban,
              ].indexOf(viewMode);
              _onItemTapped(newIndex);
            },
            itemBuilder: (BuildContext context) {
              return [
                AppLocalizations.of(context)!.listView,
                AppLocalizations.of(context)!.kanban,
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
      body: _widgetOptions[_selectedIndex], // Utilisation de la liste définie
    );
  }
}
