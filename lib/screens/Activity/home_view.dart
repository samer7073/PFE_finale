import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/calendar_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/kanban_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/list_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/create_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _viewMode = 'List view';
  bool _isDropdownVisible = false;

  // List of widgets for different views
  static final List<Widget> _widgetOptions = <Widget>[
    const ListViewPage(),
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
      _isDropdownVisible = false; // Hide dropdown after selection
    });
    int newIndex = ['List view', 'Kanban', 'Calendar'].indexOf(viewMode);
    _onItemTapped(newIndex);
  }

  // Toggle dropdown visibility
  void _toggleDropdownVisibility() {
    setState(() {
      _isDropdownVisible = !_isDropdownVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity',
              style: TextStyle(color: Colors.blue, fontSize: 25),
            ),
            GestureDetector(
              onTap: _toggleDropdownVisibility,
              child: Row(
                children: [
                  Text(
                    _viewMode,
                    style: const TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.blue),
                ],
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Action for filtering
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_active_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaskNotificationScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isDropdownVisible)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildViewModeButton('List view'),
                  _buildViewModeButton('Kanban'),
                  _buildViewModeButton('Calendar'),
                ],
              ),
            ),
          Expanded(child: _widgetOptions.elementAt(_selectedIndex)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Build view mode button
  Widget _buildViewModeButton(String mode) {
    return ElevatedButton(
      onPressed: () {
        _changeViewMode(mode);
      },
      child: Text(mode),
      style: ElevatedButton.styleFrom(
        foregroundColor: _viewMode == mode ? Colors.white : Colors.grey,
        backgroundColor: _viewMode == mode ? Colors.purple : Colors.white,
      ),
    );
  }
}
