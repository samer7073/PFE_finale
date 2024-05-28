import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/chat_room_screen.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_update_priority.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Function(String) onDelete;
  final Function(Task, int)? onStageUpdate; // Make it optional

  TaskCard({required this.task, required this.onDelete, this.onStageUpdate});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late String selectedPriority;

  @override
  void initState() {
    super.initState();
    selectedPriority = widget.task.priority;
  }

  IconData getPriorityIcon(String priority) {
    switch (priority) {
      case 'low':
        return Icons.flag_outlined;
      case 'medium':
        return Icons.flag_rounded;
      case 'high':
        return Icons.flag;
      case 'urgent':
        return Icons.priority_high;
      default:
        return Icons.flag_outlined;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.yellow;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color getProgressColor(String? stageLabel) {
    switch (stageLabel) {
      case 'To Do':
        return Colors.green;
      case 'In Progress':
        return Colors.yellow;
      case 'Blocked':
        return Colors.orange;
      case 'Review':
        return Colors.blueGrey;
      case 'Done':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String getInitials(String name) {
    return name.isNotEmpty
        ? name.split(' ').map((word) => word[0]).take(2).join().toUpperCase()
        : '';
  }

  void _deleteTask(String taskId) async {
    try {
      bool isDeleted = await deleteTasks([taskId]);
      if (isDeleted) {
        widget.onDelete(taskId); // Notify KanbanStage
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task')),
      );
    }
  }

  double calculateProgress() {
    switch (widget.task.stageLabel) {
      case 'To Do':
        return 0.1;
      case 'In Progress':
        return 0.5;
      case 'Blocked':
        return 0.7;
      case 'Review':
        return 0.9;
      case 'Done':
        return 1.0;
      default:
        return 0.0;
    }
  }

  void _updateTaskPriority(String newPriority) async {
    try {
      await updateTaskPriority(widget.task.id, newPriority);
      setState(() {
        selectedPriority = newPriority;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Priority updated to $newPriority')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update priority')),
      );
    }
  }

  IconData getTaskTypeIcon(int tasksTypeId) {
    switch (tasksTypeId) {
      case 1:
        return Icons.calendar_today;
      case 2:
        return Icons.mail_outline;
      case 3:
        return Icons.videocam;
      case 4:
        return Icons.build;
      case 5:
        return Icons.phone;
      case 6:
        return Icons.account_balance;
      case 7:
        return Icons.alternate_email;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: widget.task,
      feedback: Material(
        child: Container(
          width: 300,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // All your existing UI elements here
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.purple,
                        radius: 14,
                        child: widget.task.ownerAvatar != null &&
                                widget.task.ownerAvatar!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  'https://spherebackdev.cmk.biz:4543/storage/uploads/${widget.task.ownerAvatar}',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      getInitials(widget.task.ownerLabel ?? ''),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                getInitials(widget.task.ownerLabel ?? ''),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.task.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          getPriorityIcon(selectedPriority),
                          color: getPriorityColor(selectedPriority),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Select Priority'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: ['low', 'medium', 'high', 'urgent']
                                      .map((String value) {
                                    return RadioListTile<String>(
                                      title: Text(value),
                                      value: value,
                                      groupValue: selectedPriority,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          _updateTaskPriority(newValue);
                                          Navigator.pop(context);
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.task.startDate} - ${widget.task.startTime}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 124, 123, 123),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${widget.task.endDate} - ${widget.task.endTime}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 124, 123, 123),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Wrap(
                        spacing: 8,
                        children: widget.task.guests.map((guest) {
                          return CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://spherebackdev.cmk.biz:4543/storage/uploads/${guest['avatar']}',
                            ),
                            radius: 12,
                          );
                        }).toList(),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: calculateProgress(),
                            strokeWidth: 5,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              getProgressColor(widget.task.stageLabel),
                            ),
                          ),
                          Text(
                            '${(calculateProgress() * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.note_alt_rounded,
                          size: 18,
                          color: Colors.purple,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateTaskScreen(taskId: widget.task.id),
                            ),
                          );
                        },
                        tooltip: 'Add Note',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chat,
                          size: 18,
                          color: Colors.purple,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoomScreen(task: widget.task),
                            ),
                          );
                        },
                        tooltip: 'Chat',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirmation'),
                                content: const Text(
                                    'Are you sure you want to delete this task?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteTask(widget.task.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.purple,
                    radius: 14,
                    child: widget.task.ownerAvatar != null &&
                            widget.task.ownerAvatar!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              'https://spherebackdev.cmk.biz:4543/storage/uploads/${widget.task.ownerAvatar}',
                              width: 28,
                              height: 28,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  getInitials(widget.task.ownerLabel ?? ''),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            getInitials(widget.task.ownerLabel ?? ''),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.task.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      getPriorityIcon(selectedPriority),
                      color: getPriorityColor(selectedPriority),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Select Priority'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: ['low', 'medium', 'high', 'urgent']
                                  .map((String value) {
                                return RadioListTile<String>(
                                  title: Text(value),
                                  value: value,
                                  groupValue: selectedPriority,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      _updateTaskPriority(newValue);
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                              }).toList(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.task.startDate} - ${widget.task.startTime}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 124, 123, 123),
                  fontSize: 12,
                ),
              ),
              Text(
                '${widget.task.endDate} - ${widget.task.endTime}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 124, 123, 123),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Wrap(
                    spacing: 8,
                    children: widget.task.guests.map((guest) {
                      return CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://spherebackdev.cmk.biz:4543/storage/uploads/${guest['avatar']}',
                        ),
                        radius: 12,
                      );
                    }).toList(),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: calculateProgress(),
                        strokeWidth: 5,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          getProgressColor(widget.task.stageLabel),
                        ),
                      ),
                      Text(
                        '${(calculateProgress() * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.note_alt_rounded,
                      size: 18,
                      color: Colors.purple,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UpdateTaskScreen(taskId: widget.task.id),
                        ),
                      );
                    },
                    tooltip: 'Add Note',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat,
                      size: 18,
                      color: Colors.purple,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(task: widget.task),
                        ),
                      );
                    },
                    tooltip: 'Chat',
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      size: 18,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirmation'),
                            content: const Text(
                                'Are you sure you want to delete this task?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteTask(widget.task.id);
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(),
    );
  }
}
