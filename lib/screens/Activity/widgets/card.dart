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
  late String currentPriority;
  late String currentStageLabel;
  late Map<int, IconData> taskTypeIcons = {};
  Map<int, Stage> _stages = {};
  final Map<int, int> _stagePercents = {
    20: 25,
    22: 50,
    241: 90,
    23: 100,
    21: 0,
  };

  @override
  void initState() {
    super.initState();
    currentPriority = widget.task.priority ?? 'None';
    currentStageLabel = widget.task.stageLabel;
    _fetchTaskTypeIcons();
    _preloadStages();
  }

  Future<void> _preloadStages() async {
    try {
      _stages = await _fetchStages();
      if (mounted) {
        setState(
            () {}); // Forcer la reconstruction du widget après le chargement des stages
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

  Widget _buildAvatar(String avatar) {
    return CircleAvatar(
      backgroundColor: avatar.length == 1 ? Colors.blue : null,
      backgroundImage: avatar.length == 1
          ? null
          : NetworkImage(
              "https://spherebackdev.cmk.biz:4543/storage/uploads/$avatar"),
      radius: 15,
      child: avatar.length == 1
          ? Text(avatar, style: const TextStyle(color: Colors.white))
          : null,
    );
  }

  Widget _buildAvatars(List<String?> avatars, {int maxAvatars = 3}) {
    List<Widget> avatarWidgets = [];
    for (int i = 0; i < avatars.length && i < maxAvatars; i++) {
      avatarWidgets.add(
          Positioned(left: i * 20.0, child: _buildAvatar(avatars[i] ?? "")));
    }
    if (avatars.length > maxAvatars) {
      avatarWidgets.add(Positioned(
          left: maxAvatars * 20.0,
          child: CircleAvatar(
              radius: 15, child: Text('+${avatars.length - maxAvatars}'))));
    }
    return Container(
        width: (maxAvatars + 1) * 20.0,
        height: 40,
        child: Stack(children: avatarWidgets));
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
              _buildPriorityOption('Low', Colors.grey),
              _buildPriorityOption('Medium', Colors.blue),
              _buildPriorityOption('High', Colors.orange),
              _buildPriorityOption('Urgent', Colors.red),
              _buildPriorityOption('None', Colors.transparent),
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
          await updateTaskPriority(widget.task.id, priority);
          if (mounted) {
            setState(() {
              currentPriority = priority;
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update priority: $e')));
          }
        }
      },
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
    return GestureDetector(
      onTap: _showPriorityDialog,
      child: Stack(alignment: Alignment.center, children: [
        const Icon(Icons.flag_outlined, color: Colors.black),
        Icon(Icons.flag, color: flagColor)
      ]),
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
                    await updateTaskStage(widget.task.id, stage.id);
                    widget.onStageChanged(stage.id);
                    if (mounted) {
                      setState(() {
                        currentStageLabel = stage.label;
                        widget.task.stagePercent =
                            _stagePercents[stage.id] ?? 0;
                        widget.task.stageColor = stage.color;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Failed to update stage: $e')));
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
    DateTime startDate = _parseDate(widget.task.startDate);
    DateTime endDate = _parseDate(widget.task.endDate);
    bool isOverdue = endDate.isBefore(DateTime.now());

    IconData taskIcon =
        taskTypeIcons[widget.task.tasksTypeId] ?? Icons.help_outline;

    return Card(
      margin: const EdgeInsets.all(10.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level 1
            Row(
              children: [
                _buildAvatar(widget.task.ownerAvatar),
                const SizedBox(width: 20.0),
                Icon(taskIcon, color: _parseColor(widget.task.iconColor)),
                const SizedBox(width: 8.0),
                Text(
                  widget.task.label.length > 20
                      ? '${widget.task.label.substring(0, 20)}...'
                      : widget.task.label,
                ),
                const Spacer(),
                _buildPriorityFlag(currentPriority),
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
                        "Start: ${DateFormat('dd-MM-yyyy ').format(startDate)}"),
                    Text(
                      "End: ${DateFormat('dd-MM-yyyy ').format(endDate)}",
                      style: TextStyle(
                          color: isOverdue ? Colors.red : Colors.black),
                    ),
                  ],
                ),
                const Spacer(),
                _buildAvatars(
                    widget.task.guests
                        .map((guest) => guest['avatar'] as String?)
                        .toList(),
                    maxAvatars: 4),
              ],
            ),
            const SizedBox(height: 10.0),

            // Level 3
            if (widget.task.familyLabel != null &&
                widget.task.familyLabel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Text("Family: ${widget.task.familyLabel}"),
                    const Spacer(),
                  ],
                ),
              ),
            if (widget.task.elementLabel != null &&
                widget.task.elementLabel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  children: [
                    Text("Element: ${widget.task.elementLabel}"),
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
                        widget.task.stagePercent,
                        widget.task.stageLabel,
                        widget.task.stageColor),
                  ),
                ],
              ),
            ),

            // Level 4
            _buildAvatars(
                widget.task.followers
                    .map((follower) => follower['avatar'] as String?)
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
                    color: Colors.purple,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TaskDetailPage(taskId: widget.task.id),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.edit,
                    size: 20,
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
                ),
                IconButton(
                    icon: const Icon(
                      Icons.chat,
                      size: 20,
                      color: Colors.purple,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RommCommentairePage(
                            roomId: widget.task.roomId ?? 'null',
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
                                deleteTasks(widget.task.id).then((_) {
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
