import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/providers/langue_provider.dart';
import 'package:flutter_application_stage_project/screens/Activity/create_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_list_row.dart';
import 'package:flutter_application_stage_project/services/Activities/api_calendar_view.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Calendarviewpage extends StatefulWidget {
  const Calendarviewpage({super.key});

  @override
  _CalendarviewpageState createState() => _CalendarviewpageState();
}

class _CalendarviewpageState extends State<Calendarviewpage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Task> _tasks = [];
  Map<DateTime, List<Task>> _taskEvents = {};
  String _noTasksMessage = '';
  bool _isLoading = false; // Add this variable

  @override
  void initState() {
    super.initState();
    _fetchTasksForSelectedDay();
  }

  void _onCalendarTapped(DateTime date) {
    setState(() {
      if (_calendarFormat == CalendarFormat.month) {
        _calendarFormat = CalendarFormat.week;
      } else {
        _calendarFormat = CalendarFormat.month;
      }
    });
  }

  void _fetchTasksForSelectedDay() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final start = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final end = DateFormat('yyyy-MM-dd').format(_selectedDay);
    final tasks = await fetchTasks(start, end);

    // Sort tasks by time (assumes tasks have a startTime field)
    tasks.sort((a, b) {
      final aTime = DateFormat('HH:mm').parse(a.startTime);
      final bTime = DateFormat('HH:mm').parse(b.startTime);
      return aTime.compareTo(bTime);
    });

    setState(() {
      _tasks = tasks;
      _updateTaskEvents(tasks);
      _isLoading = false; // Stop loading

      if (tasks.isEmpty) {
        _noTasksMessage =
            'There are no tasks for ${DateFormat('dd MMMM yyyy').format(_selectedDay)}';
      } else {
        _noTasksMessage = '';
      }
    });
  }

  void _updateTaskEvents(List<Task> tasks) {
    Map<DateTime, List<Task>> taskEvents = {};
    for (var task in tasks) {
      final date = DateFormat('dd-MM-yyyy').parse(task.startDate);
      if (taskEvents[date] == null) {
        taskEvents[date] = [];
      }
      taskEvents[date]!.add(task);
    }

    // Sort tasks within each day by time
    taskEvents.forEach((key, value) {
      value.sort((a, b) {
        final aTime = DateFormat('HH:mm').parse(a.startTime);
        final bTime = DateFormat('HH:mm').parse(b.startTime);
        return aTime.compareTo(bTime);
      });
    });

    setState(() {
      _taskEvents = taskEvents;
    });
  }

  Future<bool?> _showDeleteConfirmationDialog(String taskId) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this task?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await deleteTasks(taskId);
      setState(() {
        _tasks.removeWhere((task) => task.id == taskId);
        _updateTaskEvents(_tasks);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
          'Failed to delete task: $e',
          style: TextStyle(color: Colors.white),
        )),
      );
    }
  }

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
    'AtSymbolIcon': Icons.alternate_email_outlined,
    'WebOutlined': FontAwesomeIcons.earthAfrica,
  };
  IconData _getIconData(String taskTypeIcon) {
    return iconMap[taskTypeIcon] ?? Icons.help_outline;
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

  void _editTask(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskId: task.id),
      ),
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

  @override
  Widget build(BuildContext context) {
    final langueProvider = Provider.of<LangueProvider>(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(),
        child: Column(
          children: [
            TableCalendar(
              locale: langueProvider.localeString,
              onHeaderTapped: _onCalendarTapped,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                return _taskEvents[day] ?? [];
              },
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _fetchTasksForSelectedDay();
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  color: Colors.blue, // Color for the month title
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Colors.blue, // Color for the left button
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.blue, // Color for the right button
                ),
              ),
              calendarStyle: const CalendarStyle(
                weekendTextStyle:
                    TextStyle(color: Colors.blue), // Color for weekends
                weekendDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),

                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Colors.blue,
                    )) // Show loading indicator
                  : _tasks.isEmpty
                      ? Center(
                          child: Text(
                            _noTasksMessage,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            return Slidable(
                              key: Key(task.id),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (context) =>
                                        _showDeleteConfirmationDialog(task.id)
                                            .then((value) {
                                      if (value == true) _deleteTask(task.id);
                                    }),
                                    foregroundColor: Colors.red,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                  SlidableAction(
                                    onPressed: (context) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UpdateTaskScreen(
                                            taskId: task.id,
                                          ),
                                        ),
                                      );
                                    },
                                    foregroundColor: Colors.green,
                                    icon: Icons.edit,
                                    label: 'Edit',
                                  ),
                                ],
                              ),
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
                                priorityIcon: _getPriorityIcon(task.priority),
                                priorityColor: _getPriorityColor(task.priority),
                                ownerAvatar: task.ownerAvatar,
                                stageLabel: task.stageLabel ?? 'N/A',
                                isOverdue: task.isOverdue,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
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
}
