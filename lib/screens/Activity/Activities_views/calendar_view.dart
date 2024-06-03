import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_calendar_view.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class TaskListRow extends StatelessWidget {
  final int tasksTypeId;
  final String title;
  final String owner;
  final String ownerImage;
  final String priority;
  final String endDate;
  final String endTime;
  final bool isOverdue;
  final Map<String, IconData> iconMap;
  final VoidCallback onDeleteIconTap;
  final VoidCallback onTap; // Add onTap callback

  const TaskListRow({
    super.key,
    required this.tasksTypeId,
    required this.title,
    required this.owner,
    required this.ownerImage,
    required this.priority,
    required this.endDate,
    required this.endTime,
    required this.isOverdue,
    required this.iconMap,
    required this.onDeleteIconTap,
    required this.onTap, // Initialize onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Use onTap callback
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
                      Icon(_getIconData(tasksTypeId)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.bodyText1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 5),
                      _buildPriorityFlag(priority),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    'End: $endDate $endTime',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.black,
                      fontWeight:
                          isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                    owner,
                    style: Theme.of(context).textTheme.bodyLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ownerImage.length == 1
                    ? CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          ownerImage,
                          style: const TextStyle(color: Colors.white),
                        ),
                        radius: 15,
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(
                            "https://spherebackdev.cmk.biz:4543/storage/uploads/$ownerImage"),
                        radius: 15,
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
        flagColor = Colors.grey;
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
    setState(() {
      _tasks = tasks;
      _updateTaskEvents(tasks);
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
    setState(() {
      _taskEvents = taskEvents;
    });
  }

  Future<bool?> _showDeleteConfirmationDialog(String taskId) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button for dismissal
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
      await deleteTasks(taskId); // Call your API to delete the task
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

  Widget _buildPriorityFlag(String? priority) {
    Color flagColor;
    switch (priority?.toLowerCase()) {
      case 'low':
        flagColor = Colors.grey;
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
    return iconMap[tasksTypeId] ?? Icons.help_outline;
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
            /////////////////////////////////////Calendar////////////////////////////////////
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
            ///////////////////////////////////Display Activities cards//////////////////////////////
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No Tasks For Today',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.blue,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return SwipeToDelete(
                          key: Key(task.id),
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: TaskListRow(
                              tasksTypeId: task.tasksTypeId,
                              title: task.label,
                              owner: task.ownerLabel,
                              ownerImage: task.ownerAvatar,
                              priority: task.priority,
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
                                    ), // Pass taskId to TaskDetailPage
                                  ),
                                );
                              },
                            ),
                          ),
                          onDelete: () async {
                            final bool? result =
                                await _showDeleteConfirmationDialog(task.id);
                            if (result == true) {
                              await _deleteTask(task.id);
                            }
                          },
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateTaskScreen(
                                    taskId:
                                        task.id), // Pass taskId to TaskEditPage
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwipeToDelete extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onDelete;
  final VoidCallback onEdit; // Add onEdit callback

  const SwipeToDelete({
    Key? key,
    required this.child,
    required this.onDelete,
    required this.onEdit, // Initialize onEdit
  }) : super(key: key);

  @override
  _SwipeToDeleteState createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<SwipeToDelete> {
  double offset = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          offset += details.delta.dx;
          if (offset > 0) offset = 0;
          if (offset < -150) offset = -150; // Increase limit for both icons
        });
      },
      onHorizontalDragEnd: (details) {
        if (offset <= -75) {
          // Adjust for halfway swipe
          setState(() {
            offset = -150;
          });
        } else {
          setState(() {
            offset = 0;
          });
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        widget.onEdit();
                        setState(() {
                          offset = 0;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await widget.onDelete();
                        setState(() {
                          offset = 0;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(offset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
