import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/create_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_list_row.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_tasks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    'WrenchScrewdriverIcon': FontAwesomeIcons.screwdriverWrench,
    'AtSymbolIcon': Icons.alternate_email_outlined,
    'WebOutlined': FontAwesomeIcons.earthAfrica,
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
        filteredTasks = List.from(tasks); // Copie la liste chargée
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
      isLoading = true;
    });

    try {
      if (query.isEmpty) {
        // Si la requête est vide, réinitialiser la liste filtrée avec toutes les tâches chargées
        setState(() {
          filteredTasks = List.from(tasks); // Utilise la liste existante
        });
      } else {
        // Recherche basée sur la requête
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
        isLoading = false;
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
        SnackBar(
            content: Text(
          'Failed to delete task: $e',
          style: TextStyle(color: Colors.white),
        )),
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

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 60, // Adjust the height as needed
              child: TextField(
                cursorColor: Colors.blue,
                controller: _searchController,
                decoration: InputDecoration(
                  suffix: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController
                                .clear(); // Clear the text in the controller
                            setState(
                                () {}); // Trigger UI update to hide the icon
                          },
                          icon: Center(
                            child: Icon(
                              Icons.cancel,
                              size: 20,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                  hintText: AppLocalizations.of(context)!.searchactivites,
                  hintStyle: TextStyle(
                    fontSize: 14, // Adjust font size as needed
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 12.0), // Adjust padding as needed
                  filled: true,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
                onChanged: (value) {
                  _filterTasks();
                },
              ),
            ),
          ),
          isLoading && tasks.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshTasks,
                    child: filteredTasks.isEmpty
                        ? Center(
                            child: Text(
                              AppLocalizations.of(context)!.noResultsFound,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return Slidable(
                                endActionPane: ActionPane(
                                  motion: const ScrollMotion(),
                                  children: [
                                    if (task.can_update_task == 1 &&
                                        task.is_follower == 0)
                                      SlidableAction(
                                        onPressed: (context) => _editTask(task),
                                        backgroundColor:
                                            hexToColor(task.task_type_color)
                                                .withOpacity(0.01),
                                        foregroundColor: Colors.green,
                                        icon: Icons.edit,
                                        label: 'Edit',
                                      ),
                                    if (task.can_update_task == 1)
                                      SlidableAction(
                                        onPressed: (context) =>
                                            _deleteTask(task.id),
                                        backgroundColor:
                                            Colors.red.withOpacity(0.01),
                                        foregroundColor: Colors.red,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    _navigateToDetail(task);
                                  },
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
                                    priorityIcon:
                                        _getPriorityIcon(task.priority),
                                    priorityColor:
                                        _getPriorityColor(task.priority),
                                    ownerAvatar: task.ownerAvatar,
                                    stageLabel: task.stageLabel ?? 'N/A',
                                    isOverdue: task.isOverdue,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _navigateToCreateTask,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
