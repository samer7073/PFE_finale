import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/create_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_calendar_view.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/constants/shared/config.dart';

class TaskListRow extends StatefulWidget {
  final int tasksTypeId;
  final String title;
  final String owner;
  final String ownerImage;
  final String priority;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final bool isOverdue;
  final Map<String, IconData> iconMap;
  final VoidCallback onDeleteIconTap;
  final VoidCallback onTap;

  const TaskListRow({
    super.key,
    required this.tasksTypeId,
    required this.title,
    required this.owner,
    required this.ownerImage,
    required this.priority,
    required this.startDate,
    required this.startTime,
    required this.endDate,
    required this.endTime,
    required this.isOverdue,
    required this.iconMap,
    required this.onDeleteIconTap,
    required this.onTap,
  });

  @override
  State<TaskListRow> createState() => _TaskListRowState();
}

class _TaskListRowState extends State<TaskListRow> {
  Future<String> getBaseUrl() async {
    return await Config.getApiUrl("baseUrl");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(_getIconData(widget.tasksTypeId)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: Theme.of(context).textTheme.bodyText1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      _buildPriorityFlag(widget.priority),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Start: ${widget.startDate} ${widget.startTime}',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'End: ${widget.endDate} ${widget.endTime}',
                        style: TextStyle(
                          color: widget.isOverdue ? Colors.red : Colors.black,
                          fontWeight: widget.isOverdue
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.owner,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                widget.ownerImage.length == 1
                    ? CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          widget.ownerImage,
                          style: const TextStyle(color: Colors.white),
                        ),
                        radius: 15,
                      )
                    : FutureBuilder<String>(
                        future: getBaseUrl(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text('Error loading image URL');
                          }

                          String baseUrl = snapshot.data ?? "";

                          return CircleAvatar(
                            backgroundColor: Colors.transparent,
                            backgroundImage: NetworkImage(
                              "$baseUrl/storage/uploads/${widget.ownerImage}",
                            ),
                            radius: 15,
                          );
                        },
                      ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityFlag(String? priority) {
    Color flagColor;
    switch (priority?.toLowerCase()) {
      case 'low':
        flagColor = Colors.green;
        break;
      case 'medium':
        flagColor = Colors.blue;
        break;
      case 'high':
        flagColor = Colors.orange;
        break;
      case 'urgent':
        flagColor = Colors.red;
        break;
      default:
        flagColor = Colors.transparent;
        break;
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.flag_outlined, color: Colors.black),
        Icon(Icons.flag, color: flagColor),
      ],
    );
  }

  IconData _getIconData(int tasksTypeId) {
    switch (tasksTypeId) {
      case 1:
        return widget.iconMap['CalendarOutlined'] ?? Icons.help_outline;
      case 2:
        return widget.iconMap['MailOutlined'] ?? Icons.help_outline;
      case 3:
        return widget.iconMap['VideoCameraOutlined'] ?? Icons.help_outline;
      case 4:
        return widget.iconMap['PhoneOutlined'] ?? Icons.help_outline;
      case 11:
        return widget.iconMap['WrenchScrewdriverIcon'] ?? Icons.help_outline;
      case 12:
        return widget.iconMap['BankOutlined'] ?? Icons.help_outline;
      case 16:
        return widget.iconMap['AtSymbolIcon'] ?? Icons.help_outline;
      default:
        return Icons.help_outline;
    }
  }
}

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
    _fetchTasksForSelectedDay();
  }

  void _fetchTasksForSelectedDay() async {
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
        SnackBar(content: Text('Failed to delete task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 204, 247),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            TableCalendar(
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
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: _tasks.isEmpty
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
                                backgroundColor: Colors.red.withOpacity(0.1),
                                foregroundColor: Colors.red,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                              SlidableAction(
                                onPressed: (context) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateTaskScreen(
                                        taskId: task.id,
                                      ),
                                    ),
                                  );
                                },
                                backgroundColor: Colors.green.withOpacity(0.1),
                                foregroundColor: Colors.green,
                                icon: Icons.edit,
                                label: 'Edit',
                              ),
                            ],
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: TaskListRow(
                              tasksTypeId: task.tasksTypeId,
                              title: task.label,
                              owner: task.ownerLabel,
                              ownerImage: task.ownerAvatar,
                              priority: task.priority,
                              startDate: task.startDate,
                              startTime: task.startTime,
                              endDate: task.endDate,
                              endTime: task.endTime,
                              isOverdue: task.isOverdue,
                              iconMap: iconMap,
                              onDeleteIconTap: () async {
                                final bool? result =
                                    await _showDeleteConfirmationDialog(
                                        task.id);
                                if (result == true) {
                                  await _deleteTask(task.id);
                                }
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskDetailPage(
                                      taskId: task.id,
                                    ),
                                  ),
                                );
                              },
                            ),
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
