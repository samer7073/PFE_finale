import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/calendar_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/kanban_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/list_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/create_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_notification_screen.dart';
import 'package:flutter_application_stage_project/screens/NotficationPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late String _viewMode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewMode = AppLocalizations.of(context)!.listView;
  }

  // List of widgets for different views
  static final List<Widget> _widgetOptions = <Widget>[
    const TaskListPage(),
    const KanbanBoard(),
    const Calendarviewpage(),
  ];

  // Handle item tap to switch views
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Change view mode based on selection
  void _changeViewMode(String viewMode) {
    setState(() {
      _viewMode = viewMode;
    });
    int newIndex = [
      AppLocalizations.of(context)!.listView,
      AppLocalizations.of(context)!.kanban,
      AppLocalizations.of(context)!.calendar
    ].indexOf(viewMode);
    _onItemTapped(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.activity),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_sharp,size: 30,),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
          PopupMenuButton<String>(
            initialValue: _viewMode,
            onSelected: (String newValue) {
              _changeViewMode(newValue);
            },
            itemBuilder: (BuildContext context) {
              return <String>[
                AppLocalizations.of(context)!.listView,
                AppLocalizations.of(context)!.kanban,
                AppLocalizations.of(context)!.calendar
              ].map<PopupMenuItem<String>>((String value) {
                return PopupMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
        ],
      ),
    );
  }
}
