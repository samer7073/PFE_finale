// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/pipeline.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/comments_room.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/screens/RoomCommenatire.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_task_type.dart';
import 'package:flutter_application_stage_project/services/Activities/api_update_priority.dart';
import 'package:flutter_application_stage_project/services/Activities/api_update_stage_task.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/shared/config.dart';

class TaskCard1 extends StatefulWidget {
  final Task task;
  final void Function(int newStageId) onStageChanged;
  final VoidCallback onDelete;

  const TaskCard1({
    Key? key,
    required this.task,
    required this.onStageChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  _TaskCard1State createState() => _TaskCard1State();
}

class _TaskCard1State extends State<TaskCard1> {
  late Task _task;
  late String _imageUrl = "";
  late Map<int, IconData> taskTypeIcons = {};
  Map<int, Stage> _stages = {};
  final Map<int, int> _stagePercents = {
    20: 25,
    22: 50,
    241: 90,
    23: 100,
    21: 0,
  };
  late Future<String> imageUrlFuture;

  @override
  void initState() {
    super.initState();
    imageUrlFuture = Config.getApiUrl("urlImage");

    _task = widget.task;
    _fetchTaskTypeIcons();
    _preloadStages();
    log("999999999999999999999999999999999999" + _task.toString());
  }

  Future<void> _preloadStages() async {
    try {
      _stages = await _fetchStages();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to preload stages: $e')),
        );
      }
    }
  }

  Future<void> _fetchTaskTypeIcons() async {
    try {
      List<TaskType> taskTypes = await fetchTaskTypes();
      if (mounted) {
        setState(() {
          taskTypeIcons = {
            for (var taskType in taskTypes)
              taskType.id: _getIconData(taskType.icon)
          };
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch task type icons: $e')),
        );
      }
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'CalendarOutlined':
        return Icons.calendar_today;
      case 'MailOutlined':
        return Icons.mail_outline;
      case 'VideoCameraOutlined':
        return Icons.videocam_outlined;
      case 'WrenchScrewdriverIcon':
        return Icons.build;
      case 'PhoneOutlined':
        return Icons.phone_outlined;
      case 'BankOutlined':
        return Icons.account_balance;
      case 'AtSymbolIcon':
        return Icons.alternate_email;
      default:
        return Icons.help_outline;
    }
  }

  DateTime _parseDate(String date) {
    try {
      return DateFormat('dd-MM-yyyy').parse(date);
    } catch (e) {
      throw FormatException('Invalid date format: $date');
    }
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xff')));
    } catch (e) {
      return Colors.black; // Fallback color if parsing fails
    }
  }

  Widget _buildAvatar(String? avatar, String label) {
    if (avatar!.isEmpty || avatar.length == 1) {
      String initial = avatar != null && avatar.length == 1
          ? avatar
          : (label.isNotEmpty ? label[0].toUpperCase() : '?');
      return CircleAvatar(
        radius: 15,
        backgroundColor: Colors.blueGrey, // Set a background color if needed
        child: Text(
          initial,
          style: TextStyle(color: Colors.white),
        ),
      );
    } else {
      return FutureBuilder<String>(
        future: imageUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 15,
              child: CircularProgressIndicator(),
            );
          }

          String baseUrl = snapshot.data ?? "";
          return CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 15,
            child: CachedNetworkImage(
              imageUrl: "$baseUrl$avatar",
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        },
      );
    }
  }

  Widget _buildAvatars(List<Map<String, String?>> avatarsAndLabels,
      {int maxAvatars = 3}) {
    List<Widget> avatarWidgets = [];
    for (int i = 0; i < avatarsAndLabels.length && i < maxAvatars; i++) {
      avatarWidgets.add(Positioned(
        left: i * 20.0,
        child: _buildAvatar(
            avatarsAndLabels[i]['avatar'], avatarsAndLabels[i]['label']!),
      ));
    }
    if (avatarsAndLabels.length > maxAvatars) {
      avatarWidgets.add(Positioned(
        left: maxAvatars * 20.0,
        child: CircleAvatar(
          radius: 15,
          backgroundColor: const Color.fromARGB(
              255, 50, 63, 69), // Set a background color if needed
          child: Text(
            '+${avatarsAndLabels.length - maxAvatars}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
    }
    return Container(
      width: (maxAvatars + 1) * 30.0, // Adjust width to ensure full display
      height: 40,
      color: Colors.transparent, // Ensure background is transparent
      child: Stack(children: avatarWidgets),
    );
  }

  void _showPriorityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPriorityOption('Low', Colors.green),
              _buildPriorityOption('Medium', Colors.blue),
              _buildPriorityOption('High', Colors.orange),
              _buildPriorityOption('Urgent', Colors.red),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriorityOption(String priority, Color color) {
    return ListTile(
      leading: Stack(alignment: Alignment.center, children: [
        const Icon(Icons.flag_outlined, color: Colors.black),
        Icon(Icons.flag, color: color)
      ]),
      title: Text(priority),
      onTap: () async {
        Navigator.of(context).pop();
        try {
          await updateTaskPriority(_task.id, priority);
          if (mounted) {
            setState(() {
              _task.priority = priority;
            });
            _showUpdateDialog('Priority updated to $priority');
          }
        } catch (e) {
          if (mounted) {
            _showUpdateDialog('Failed to update priority: $e');
          }
        }
      },
    );
  }

  void _showStageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Stage'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _stages.entries.map((entry) {
              Stage stage = entry.value;
              return ListTile(
                leading: Container(
                    width: 24,
                    height: 24,
                    color:
                        Color(int.parse(stage.color.replaceAll('#', '0xff')))),
                title: Text(stage.label),
                onTap: () async {
                  Navigator.of(context).pop();
                  try {
                    await updateTaskStage(_task.id, stage.id);
                    widget.onStageChanged(stage.id);
                    if (mounted) {
                      setState(() {
                        _task.stageLabel = stage.label;
                        _task.stagePercent = _stagePercents[stage.id] ?? 0;
                        _task.stageColor = stage.color;
                      });
                      _showUpdateDialog('Stage updated to ${stage.label}');
                    }
                  } catch (e) {
                    if (mounted) {
                      _showUpdateDialog('Failed to update stage: $e');
                    }
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showUpdateDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriorityFlag(String priority) {
    Color flagColor;
    switch (priority.toLowerCase()) {
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
    return GestureDetector(
      onTap: _showPriorityDialog,
      child: Stack(alignment: Alignment.center, children: [
        const Icon(Icons.flag_outlined, color: Colors.black),
        Icon(Icons.flag, color: flagColor)
      ]),
    );
  }

  Future<Map<int, Stage>> _fetchStages() async {
    // Replace with your API call to fetch stages
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return {
      20: Stage(id: 20, label: 'To Do', color: '#10b981'),
      22: Stage(id: 22, label: 'In Progress', color: '#ec4899'),
      241: Stage(id: 241, label: 'Review', color: '#7c3aed'),
      23: Stage(id: 23, label: 'Done', color: '#2563eb'),
      21: Stage(id: 21, label: 'Blocked', color: '#f59e0b'),
    };
  }

  Widget _buildStageProgressIndicator(
      int stagePercent, String stageLabel, String stageColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: stagePercent / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_parseColor(stageColor)),
        ),
        Text(
          '${stagePercent}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = _parseDate(_task.startDate);
    DateTime endDate = _parseDate(_task.endDate);
    bool isOverdue = endDate.isBefore(DateTime.now());

    IconData taskIcon = taskTypeIcons[_task.tasksTypeId] ?? Icons.help_outline;

    return Card(
      borderOnForeground: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
        side: BorderSide(
          color: const Color.fromARGB(255, 225, 222,
              222), // Changez cette couleur pour la couleur souhaitée
          width:
              1.0, // Changez cette valeur pour ajuster l'épaisseur de la bordure
        ),
      ),
      color: Colors.white,
      margin: const EdgeInsets.all(10.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _task.familyLabel,
              style: TextStyle(color: Colors.amber),
            ),
            // Level 1
            Row(
              children: [
                _buildAvatar(_task.ownerAvatar, _task.ownerLabel),
                const SizedBox(width: 20.0),
                Icon(taskIcon, color: _parseColor(_task.iconColor)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    _task.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildPriorityFlag(_task.priority ?? 'None'),
              ],
            ),
            const SizedBox(height: 10.0),

            // Level 2
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Start: ${DateFormat('dd-MM-yyyy').format(startDate)}"),
                    Text(
                      "End: ${DateFormat('dd-MM-yyyy').format(endDate)}",
                      style: TextStyle(
                          color: isOverdue ? Colors.red : Colors.black),
                    ),
                  ],
                ),
                const Spacer(),
                _buildAvatars(
                    _task.guests
                        .map((guest) => {
                              'avatar': guest['avatar'] as String?,
                              'label': guest['label'] as String
                            })
                        .toList(),
                    maxAvatars: 4),
              ],
            ),
            const SizedBox(height: 10.0),

            // Level 3
            if (_task.familyLabel != null && _task.familyLabel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Text("Family: ${_task.familyLabel}"),
                    const Spacer(),
                  ],
                ),
              ),
            if (_task.elementLabel != null && _task.elementLabel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Text("Element: ${_task.elementLabel}"),
                    const Spacer(),
                  ],
                ),
              ),

            // Stage Progress Indicator
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: _showStageDialog,
                    child: _buildStageProgressIndicator(
                        _task.stagePercent, _task.stageLabel, _task.stageColor),
                  ),
                ],
              ),
            ),

            // Level 4
            _buildAvatars(
                _task.followers
                    .map((follower) => {
                          'avatar': follower['avatar'] as String?,
                          'label': follower['label'] as String
                        })
                    .toList(),
                maxAvatars: 4),
            const SizedBox(height: 10.0),

            // Level 5
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    size: 20,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailPage(taskId: _task.id),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 20,
                    color: Colors.blue,
                  ),
                  onPressed: () async {
                    final updatedTask = await Navigator.push<Task>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UpdateTaskScreen(taskId: _task.id),
                      ),
                    );

                    if (updatedTask != null) {
                      setState(() {
                        _task = updatedTask;
                      });
                    }
                  },
                ),
                IconButton(
                    icon: const Icon(
                      Icons.chat,
                      size: 20,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RommCommentairePage(
                            roomId: _task.roomId ?? 'null',
                          ),
                        ),
                      );
                    }),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                    size: 20,
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
                                deleteTasks(_task.id).then((_) {
                                  Navigator.of(context).pop();
                                  widget
                                      .onDelete(); // Notify parent of deletion
                                });
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
    );
  }
}
