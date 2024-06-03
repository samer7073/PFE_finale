import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';

class TaskListRow extends StatefulWidget {
  final int tasksTypeId;
  final String title;
  final String owner;
  final String ownerImage;
  final String priority;
  final String endDate;
  final String endTime;
  final bool isOverdue;
  final Map<String, IconData> iconMap;
  final String taskId;
  final VoidCallback onDelete;

  const TaskListRow({
    Key? key,
    required this.tasksTypeId,
    required this.title,
    required this.owner,
    required this.ownerImage,
    required this.priority,
    required this.endDate,
    required this.endTime,
    required this.isOverdue,
    required this.iconMap,
    required this.taskId,
    required this.onDelete,
  }) : super(key: key);

  @override
  _TaskListRowState createState() => _TaskListRowState();
}

class _TaskListRowState extends State<TaskListRow>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void _handleSwipe() {
    if (_dragExtent.abs() > 100) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.primaryDelta!;
          if (_dragExtent > 0) _dragExtent = 0; // Prevent dragging to the right
          if (_dragExtent < -150)
            _dragExtent = -150; // Limit dragging to the left
        });
      },
      onHorizontalDragEnd: (details) {
        _handleSwipe();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_dragExtent < -50) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UpdateTaskScreen(taskId: widget.taskId),
                          ),
                        );
                        setState(() {
                          _dragExtent = 0;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool? result = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Task'),
                            content: const Text(
                                'Are you sure you want to delete this task?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (result == true) {
                          print("Delete task with ID: ${widget.taskId}");
                          widget.onDelete(); // Call the onDelete callback
                        }
                        setState(() {
                          _dragExtent = 0;
                        });
                      },
                    ),
                  ],
                  const SizedBox(width: 20),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: Dismissible(
              key: Key(widget.taskId),
              direction:
                  DismissDirection.none, // Disable default dismiss behavior
              background: Container(),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TaskDetailPage(taskId: widget.taskId),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(_getIconData(widget.tasksTypeId)),
                              const SizedBox(width: 5),
                              Text(
                                widget.title,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              const SizedBox(width: 5),
                              _buildPriorityFlag(widget.priority),
                            ],
                          ),
                          Text(
                            'End: ${widget.endDate} ${widget.endTime}',
                            style: TextStyle(
                              color:
                                  widget.isOverdue ? Colors.red : Colors.black,
                              fontWeight: widget.isOverdue
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.owner,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          /*
                          widget.ownerImage.isEmpty
                              ? CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    widget.owner[0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  radius: 15,
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "https://spherebackdev.cmk.biz:4543/storage/uploads/${widget.ownerImage}"),
                                  radius: 15,
                                ),
                                */
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityFlag(String priority) {
    Color flagColor;
    switch (priority.toLowerCase()) {
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
        Icon(Icons.flag, color: flagColor)
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
