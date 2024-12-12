import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_type.dart';
import 'package:flutter_application_stage_project/screens/taskKpi_page.dart';

import 'package:flutter_slidable/flutter_slidable.dart'; // Ajoute cet import
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_list_row.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import '../../core/constants/shared/config.dart';
import 'package:http/http.dart' as http;

class TaskListPage extends StatefulWidget {
  final String title;
  final String start;
  final String end;
  final int? roles;
  final int? type_task;
  final int? overdue;

  const TaskListPage({
    Key? key,
    required this.title,
    required this.start,
    required this.end,
     this.roles,
     this.type_task,
     this.overdue
  }) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  late Future<List<Task>> tasksFuture;
  final GlobalKey<TaskKpiPageState> kpiKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    tasksFuture = fetchTasks(widget.start, widget.end,roles: widget.roles,type_task: widget.type_task,overdue: widget.overdue); // Fetch tasks on init
  }
   IconData _getIconData(String taskTypeIcon) {
    return iconMap[taskTypeIcon] ?? Icons.help_outline;
  }


  // Fetch tasks from API with optional priority filter
  Future<List<Task>> fetchTasks(String start, String end, {int? roles,int? type_task,int? overdue}) async {
    final baseUrl = await Config.getApiUrl('getTasksCalendar');
    final url = Uri.parse(baseUrl);
    log("Fetching tasks from: $url");
    log("Start: $start, End: $end , roles $roles , task_type : $type_task");

    final token = await SharedPrefernce.getToken("token");
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode({
      'start': start,
      'end': end,
      'roles': roles, // Optional priority filter
      'type_task': type_task, // Optional priority filter
      'overdue': overdue, // Optional priority filter
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final taskData = data['data'] as List;
      final tasks = taskData.map((item) => Task.fromJson(item)).toList();
      return tasks;
    } else {
      final errorResponse = json.decode(response.body);
      throw Exception('Failed to load tasks: ${errorResponse['message'] ?? 'Unknown error'}');
    }
  }

  // Edit task and refresh the UI
  void _editTask(Task task) async {
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskId: task.id),
      ),
    );

    if (updatedTask == true) {
      setState(() {
        tasksFuture =fetchTasks(widget.start, widget.end,roles: widget.roles,type_task: widget.type_task,overdue: widget.overdue); 
      });
    }
  }

  // Delete task and refresh the UI
  void _deleteTask(String taskId) async {
    try {
      await deleteTasks(taskId);
      kpiKey.currentState?.futureApiResponse; // Rafraîchit la vue kanban
      setState(() {
       // kpiKey.currentState?.ApiTaskKpi.getApiResponse( DateFormat('yyyy-MM-dd').format(DateTime.now()), DateFormat('yyyy-MM-dd').format(DateTime.now()));
        tasksFuture = fetchTasks(widget.start, widget.end,roles: widget.roles,type_task: widget.type_task,overdue: widget.overdue); 
      });
    } catch (e) {
      log("Error deleting task: $e");
    }
  }

  // Navigate to task details page
  void _navigateToDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(taskId: task.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      appBar: AppBar(
        leading: 
        IconButton(onPressed: (){
          Navigator.pop(context, true);
        }, icon: Icon(Icons.arrow_back_ios)),
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Task>>(
        future: tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          } else if (snapshot.hasError) {
            log('Error fetching tasks: ${snapshot.error}');
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final tasks = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return Slidable(
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    children: [
                      if (task.can_update_task == 1 && task.is_follower == 0)
                        SlidableAction(
                          onPressed: (context) => _editTask(task),
                          backgroundColor: hexToColor(task.task_type_color).withOpacity(0.01),
                          foregroundColor: Colors.green,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                      if (task.can_update_task == 1)
                        SlidableAction(
                          onPressed: (context) => _deleteTask(task.id),
                          backgroundColor: Colors.red.withOpacity(0.01),
                          foregroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _navigateToDetail(task),
                    child: TaskListRow(
                      can_update_task: task.can_update_task,
                      is_follower: task.is_follower,
                      start_date: task.startDate,
                      start_time: task.startTime,
                      task_type_color: task.task_type_color,
                      taskIcon: _getIconData(task.task_type_icon),
                      taskId: task.id,
                      taskLabel: task.label,
                      ownerLabel: task.ownerLabel,
                      startDate: task.startDate,
                      endDate: task.endDate,
                      endTime: task.endTime,
                      priority: task.priority,
                      priorityIcon: Icons.flag,
                      priorityColor: Colors.red,
                      ownerAvatar: task.ownerAvatar,
                      stageLabel: task.stageLabel ?? 'N/A',
                      isOverdue: task.isOverdue,
                     
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Text('No tasks available for this range.'),
            );
          }
        },
      ),
    );
  }

  hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}