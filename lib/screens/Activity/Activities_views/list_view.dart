import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/create_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_list_row.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_tasks.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({Key? key}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Map<String, IconData> iconMap = {
    'CalendarOutlined': Icons.calendar_today,
    'MailOutlined': Icons.mail_outline,
    'VideoCameraOutlined': Icons.videocam,
    'WrenchScrewdriverIcon': Icons.build,
    'PhoneOutlined': Icons.phone,
    'BankOutlined': Icons.account_balance,
    'AtSymbolIcon': Icons.alternate_email,
  };
  bool isLoading = false;
  int currentPage = 1;
  bool hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _loadAllTasks();
    _searchController.addListener(_filterTasks);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAllTasks() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await TaskService.fetchTasks(currentPage);
      final List<Task> loadedTasks = response['tasks'];
      final int lastPage = response['meta']['last_page'];

      if (!mounted) return;
      setState(() {
        tasks.addAll(loadedTasks);
        filteredTasks = tasks;
      });

      currentPage++;
      if (currentPage > lastPage) {
        hasMorePages = false;
      }
    } catch (e) {
      log('Error loading tasks: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMorePages) {
      _loadAllTasks();
    }
  }

  void _filterTasks() {
    final query = _searchController.text.toLowerCase();
    if (!mounted) return;
    setState(() {
      filteredTasks = tasks.where((task) {
        return task.label.toLowerCase().contains(query) ||
            task.ownerLabel.toLowerCase().contains(query) ||
            task.priority.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await deleteTasks(taskId);
      if (!mounted) return;
      setState(() {
        tasks.removeWhere((task) => task.id == taskId);
        _filterTasks();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  Future<void> _refreshTasks() async {
    if (!mounted) return;
    setState(() {
      tasks.clear();
      filteredTasks.clear();
      currentPage = 1;
      hasMorePages = true;
    });
    await _loadAllTasks();
  }

  void _editTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskId: task.id),
      ),
    );
  }

  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this Task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask(task.id);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(taskId: task.id),
      ),
    );
  }

  Future<void> _navigateToCreateTask() async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
    );

    if (newTask != null && mounted) {
      setState(() {
        tasks.add(newTask);
        _filterTasks();
      });
    }
  }

  IconData _getIconData(int tasksTypeId) {
    switch (tasksTypeId) {
      case 1:
        return iconMap['CalendarOutlined'] ?? Icons.help_outline;
      case 2:
        return iconMap['MailOutlined'] ?? Icons.help_outline;
      case 3:
        return iconMap['VideoCameraOutlined'] ?? Icons.help_outline;
      case 4:
        return iconMap['PhoneOutlined'] ?? Icons.help_outline;
      case 11:
        return iconMap['WrenchScrewdriverIcon'] ?? Icons.help_outline;
      case 12:
        return iconMap['BankOutlined'] ?? Icons.help_outline;
      case 16:
        return iconMap['AtSymbolIcon'] ?? Icons.help_outline;
      default:
        return Icons.help_outline;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent':
        return Icons.flag;
      case 'high':
        return Icons.outlined_flag;
      case 'medium':
        return Icons.flag_outlined;
      case 'low':
        return Icons.flag_outlined;
      default:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading && tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshTasks,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: filteredTasks.length + (hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredTasks.length) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final task = filteredTasks[index];
                        return TaskListRow(
                          taskIcon: _getIconData(task.tasksTypeId),
                          taskId: task.id,
                          taskLabel: task.label,
                          ownerLabel: task.ownerLabel,
                          startDate: task.startDate,
                          endDate: task.endDate,
                          endTime: task.endTime,
                          priority: task.priority,
                          priorityIcon: _getPriorityIcon(task.priority),
                          priorityColor: _getPriorityColor(task.priority),
                          ownerAvatar: task.ownerAvatar,
                          stageLabel: task.stageLabel ?? 'N/A',
                          isOverdue: task.isOverdue,
                          onDelete: () => _confirmDelete(task),
                          onEdit: () => _editTask(task),
                          onTap: () => _navigateToDetail(task),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTask,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
