// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/create_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_list_row.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_tasks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    'BankOutlined': Icons.account_balance,
    'BellOutlined': Icons.notifications_outlined,
    'CalendarOutlined': Icons.calendar_today,
    'CameraOutlined': Icons.camera_alt_outlined,
    'CarOutlined': Icons.directions_car_outlined,
    'CheckCircleOutlined': Icons.check_circle_outline,
    'CommentOutlined': Icons.comment_outlined,
    'CreditCardOutlined': Icons.credit_card_outlined,
    'EditOutlined': Icons.edit_outlined,
    'FacebookOutlined': FontAwesomeIcons.facebook,
    'FieldTimeOutlined': Icons.access_time,
    'FolderOutlined': Icons.folder_outlined,
    'GlobalOutlined': Icons.language,
    'InboxOutlined': Icons.inbox_outlined,
    'InstagramOutlined': FontAwesomeIcons.instagram,
    'MailOutlined': Icons.mail_outline,
    'MessageOutlined': Icons.message_outlined,
    'MobileOutlined': Icons.smartphone_outlined,
    'PhoneOutlined': Icons.phone_outlined,
    'ReadOutlined': Icons.book_outlined,
    'SettingOutlined': Icons.settings_outlined,
    'UploadOutlined': Icons.cloud_upload_outlined,
    'UserOutlined': Icons.person_outline,
    'VideoCameraOutlined': Icons.videocam_outlined,
    'WarningOutlined': Icons.warning_outlined,
    'WhatsAppOutlined': FontAwesomeIcons.whatsapp,
    'WrenchScrewdriverIcon':
        FontAwesomeIcons.screwdriverWrench, // Icône pour WrenchScrewdriver
    'AtSymbolIcon': Icons.alternate_email_outlined
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

  Future<void> _filterTasks() async {
    final query = _searchController.text.toLowerCase();
    if (!mounted) return;

    setState(() {
      isLoading = true; // Active le chargement au début de la recherche
    });

    try {
      if (query.isEmpty) {
        // Si la requête de recherche est vide, charger toutes les tâches pour réinitialiser la liste filtrée
        await _loadAllTasks();
      } else {
        // Sinon, effectuer une recherche basée sur la requête
        final List<Task> searchResults = await TaskService.searchTasks(query);
        if (!mounted) return;

        setState(() {
          filteredTasks = searchResults;
        });
      }
    } catch (e) {
      log('Error filtering tasks: $e');
      if (!mounted) return;

      setState(() {
        filteredTasks = [];
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading =
            false; // Désactive le chargement une fois la recherche terminée
      });
    }
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
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask(task.id);
              },
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.blue),
              ),
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

  IconData _getIconData(String taskTypeIcon) {
    return iconMap[taskTypeIcon] ?? Icons.help_outline;
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.grey;
      default:
        return Colors.transparent;
        ;
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
          ? const Center(child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 60, // Adjust the height as needed
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
  suffix: _searchController.text.isEmpty
      ? null
      : IconButton(
          onPressed: () {
            _searchController.clear(); // Clear the text in the controller
            setState(() {}); // Trigger UI update to hide the icon
          },
          icon: Center(
            child: Icon(
              Icons.cancel,
              size: 20,
              color: Colors.blue,
            ),
          ),
        ),
  hintText: 'Search tasks...',
  hintStyle: TextStyle(
    fontSize: 14, // Adjust font size as needed
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(16.0),
    borderSide: BorderSide.none,
  ),
  contentPadding:
      EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0), // Adjust padding as needed
  filled: true,
 
  prefixIcon: const Icon(
    Icons.search,
    color: Colors.blue,
    size: 20, // Adjust icon size as needed
  ),
),
                      style: TextStyle(
                        fontSize: 14, // Adjust font size as needed
                      ),
                      onChanged: (text) {
                        setState(
                            () {}); // Trigger UI update to show/hide the icon
                      },
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
                              child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
                        }
                        final task = filteredTasks[index];
                        return TaskListRow(
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
