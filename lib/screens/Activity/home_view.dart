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
    _viewMode = AppLocalizations.of(context).listView;
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
      AppLocalizations.of(context).listView,
      AppLocalizations.of(context).kanban,
      AppLocalizations.of(context).calendar
    ].indexOf(viewMode);
    _onItemTapped(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              value: _viewMode,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _changeViewMode(newValue);
                }
              },
              items: <String>[
                AppLocalizations.of(context).listView,
                AppLocalizations.of(context).kanban,
                AppLocalizations.of(context).calendar
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
              style: const TextStyle(color: Colors.blue, fontSize: 16),
              dropdownColor: Colors.white,
            ),
            Expanded(
              child: Center(
                child: Text(
                  AppLocalizations.of(context).activity,
                  style: TextStyle(color: Colors.blue, fontSize: 24),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationPage()),
                );
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
        ],
      ),
    );
  }
}
