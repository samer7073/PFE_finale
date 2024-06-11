import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/calendar_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/kanban_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/list_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/create_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_notification_screen.dart';
import 'package:flutter_application_stage_project/screens/NotficationPage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _viewMode = 'List view';

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
    int newIndex = ['List view', 'Kanban', 'Calendar'].indexOf(viewMode);
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
              items: <String>['List view', 'Kanban', 'Calendar']
                  .map<DropdownMenuItem<String>>((String value) {
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
            const Expanded(
              child: Center(
                child: Text(
                  'Activity',
                  style: TextStyle(color: Colors.blue, fontSize: 24),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_active_rounded),
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
