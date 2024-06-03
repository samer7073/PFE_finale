import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_list_row.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_tasks.dart';

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Future<List<Task>> futureTasks;
  List<Task> tasks = []; // List to store tasks
  List<Task> filteredTasks = []; // List to store filtered tasks
  final TextEditingController _searchController = TextEditingController();
  Map<String, IconData> iconMap = {
    'CalendarOutlined': Icons.calendar_today,
    'MailOutlined': Icons.mail_outline,
    'VideoCameraOutlined': Icons.videocam,
    'WrenchScrewdriverIcon': Icons.build,
    'PhoneOutlined': Icons.phone,
    'BankOutlined': Icons.account_balance,
    'AtSymbolIcon': Icons.alternate_email,
  };

  @override
  void initState() {
    super.initState();
    futureTasks = fetchTasks();
    futureTasks.then((loadedTasks) {
      setState(() {
        tasks = loadedTasks;
        filteredTasks = loadedTasks; // Initialize filteredTasks with all tasks
      });
    });
    _searchController.addListener(_filterTasks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTasks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredTasks = tasks.where((task) {
        return task.label.toLowerCase().contains(query) ||
            task.ownerLabel.toLowerCase().contains(query) ||
            task.priority.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _deleteTask(String taskId) {
    setState(() {
      tasks.removeWhere((task) => task.id == taskId);
      _filterTasks(); // Update the filtered list after deleting a task
    });
    // Call your API to delete the task
    print("Task with ID: $taskId deleted");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks available'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskListRow(
                        tasksTypeId: task.tasksTypeId,
                        title: task.label,
                        owner: task.ownerLabel,
                        ownerImage: task.ownerAvatar,
                        priority: task.priority,
                        endDate: task.endDate,
                        endTime: task.endTime,
                        isOverdue: task.isOverdue,
                        iconMap: iconMap,
                        taskId: task.id,
                        onDelete: () => _deleteTask(task.id),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
