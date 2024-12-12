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
  final GlobalKey<DealsPageState> dealsListKey = GlobalKey();
  final GlobalKey<PipelineScreenState> dealsKanbanKey = GlobalKey();

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    // Initialisez _widgetOptions ici
    _widgetOptions = [
      DealsPage(key: dealsListKey),
      PipelineScreen(
        idFamily: "3",
        key: dealsKanbanKey, // Passer la clé ici
      ),
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


Future<void> _adddeal() async {
  final adddeal = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddElement(
        family_id: "3",
        titel: AppLocalizations.of(context)!.deal,
      ),
    ),
  );

  if (adddeal == true) {
    // Rafraîchir la vue active en fonction de l'index sélectionné
    if (_selectedIndex == 0) {
      dealsListKey.currentState?.fetchDeals(); // Rafraîchit la liste des tickets
    } else if (_selectedIndex == 1) {
      dealsKanbanKey.currentState?.initializeFirstStage(); // Rafraîchit la vue kanban
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
        _adddeal();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
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
