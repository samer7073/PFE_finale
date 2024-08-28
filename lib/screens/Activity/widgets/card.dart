// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

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
import '../../../services/Activities/api_get_stage.dart';
import '../../homeNavigate_page.dart';

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

  late Map<int, IconData> taskTypeIcons = {};
  Map<int, Stage> _stages = {};

  late Future<String> imageUrlFuture;
  List<dynamic> stages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    imageUrlFuture = Config.getApiUrl("urlImage");

    _task = widget.task;

    _fetchTaskTypeIcons();

    fetchStagesFromApi();
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
              child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
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
              placeholder: (context, url) => CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
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
      final label = avatarsAndLabels[i]['label'];
      avatarWidgets.add(Positioned(
        left: i * 20.0,
        child: Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          verticalOffset: 48,
          height: 50,
          textStyle: TextStyle(color: Colors.white),
          message: "Guest: $label",
          child: _buildAvatar(
              avatarsAndLabels[i]['avatar'], avatarsAndLabels[i]['label']!),
        ),
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

  Widget _buildAvatarsFollowers(List<Map<String, String?>> avatarsAndLabels,
      {int maxAvatars = 3}) {
    List<Widget> avatarWidgets = [];
    for (int i = 0; i < avatarsAndLabels.length && i < maxAvatars; i++) {
      final label = avatarsAndLabels[i]['label'];
      avatarWidgets.add(Positioned(
        left: i * 20.0,
        child: Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          verticalOffset: 48,
          height: 50,
          textStyle: TextStyle(color: Colors.white),
          message: "Follower: $label",
          child: _buildAvatar(
              avatarsAndLabels[i]['avatar'], avatarsAndLabels[i]['label']!),
        ),
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
              _buildPriorityOption('Low', Colors.grey),
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

  

  Widget _buildStageProgressIndicator(
      int stagePercent, String stageLabel, String stageColor) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            minHeight: 7,
            value: stagePercent / 100,
            color: Colors.blue,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_parseColor(stageColor)),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          '${stagePercent}%',
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }

  void _onPopupMenuSelected(String value) {
    switch (value) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateTaskScreen(taskId: _task.id),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog();
        break;
      case 'details':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(taskId: _task.id),
          ),
        );
        break;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await deleteTasks(_task.id);
                  widget.onDelete();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete task: $e')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showStageDialogKanban(String? stageLabel, String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text('Selected Stage '),
              Text(
                stageLabel ?? "No pipeline available",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: hexToColor(_task.stageColor),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width:
                double.maxFinite, // Ensure the dialog takes up the full width
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 16),
                  if (stages.isNotEmpty) ...MenuItems(stages, id),
                  if (stages.isEmpty)
                    Text(
                      "No stages available",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> MenuItems(List<dynamic> modules, String id) {
    List<Widget> items = [];
    for (var module in modules) {
      String moduleName = module['label'];

      items.add(Text(
        moduleName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ));

      List<dynamic> stages = module['stages'];
      for (var stage in stages) {
        Color stageColor =
            Color(int.parse(stage['color'].replaceFirst('#', '0xff')));
        items.add(GestureDetector(
          onTap: () async {
            try {
              // Attempt to update the task stage
              await updateTaskStage(id, stage['id']);
              Navigator.of(context).pop();

              widget.onStageChanged(stage['id']);
              if (mounted) {
                setState(() {
                  _task.stageLabel = stage["label"];
                  _task.stagePercent = _task.stagePercent;
                  _task.stageColor = stage["color"];
                });
                _showUpdateDialog('Stage updated to ${stage['label']}');
              }
            } catch (e) {
              if (mounted) {
                _showUpdateDialog('Failed to update stage: $e');
              }
            }
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.brightness_1, color: stageColor, size: 12),
              const SizedBox(width: 10),
              SizedBox(
                height: 50,
              ),
              Expanded(
                child: Text(stage['label']),
              ),
            ],
          ),
        ));
      }
      items.add(const SizedBox(height: 20));
    }
    return items;
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> fetchStagesFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedStages = await fetchStages();
      setState(() {
        stages = fetchedStages;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load stages: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime startDate = _parseDate(_task.startDate);
    DateTime endDate = _parseDate(_task.endDate);
    bool isOverdue = endDate.isBefore(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: Colors.grey.shade300,
            width: 1), // Bordure grise de 1 pixel de large
        borderRadius: BorderRadius.circular(15), // Coins arrondis (facultatif)
      ),
      //borderOnForeground: false,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      //color: Colors.white,
      margin: const EdgeInsets.all(10.0),
      //elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildPriorityFlag(_task.priority ?? 'None'),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      widget.task.task_type_label,
                      style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 59, 85, 251),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: _onPopupMenuSelected,
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem<String>(
                        value: 'details',
                        child: ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Details'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline),
                          title: Text('Delete'),
                        ),
                      ),
                    ];
                  },
                  icon: Icon(Icons.more_horiz_outlined, color: Colors.black),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: Text(
                    _task.label,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                //_buildPriorityFlag(_task.priority ?? 'None'),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              "Progress",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            SizedBox(
              height: 5,
            ),
            // Stage Progress Indicator

            GestureDetector(
              onTap: () {
                _showStageDialogKanban(_task.stageLabel, _task.id);
              },
              child: _buildStageProgressIndicator(
                  _task.stagePercent, _task.stageLabel, _task.stageColor),
            ),
            SizedBox(
              height: 10,
            ),

            // Level 2
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: Colors.blue), // Icône pour le début
                    SizedBox(width: 4), // Espacement entre l'icône et le texte
                    Text(" ${DateFormat('dd-MM-yyyy').format(startDate)}"),
                    SizedBox(width: 16), // Espacement entre les deux paires
                    Icon(Icons.event, color: Colors.red), // Icône pour la fin
                    SizedBox(width: 4), // Espacement entre l'icône et le texte
                    Text(
                      " ${DateFormat('dd-MM-yyyy').format(endDate)}",
                      style: TextStyle(
                        color: isOverdue ? Colors.red : Colors.black,
                      ),
                    ),
                  ],
                ),
                if (_task.guests.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildAvatars(
                      _task.guests
                          .map((guest) => {
                                'avatar': guest['avatar'] as String?,
                                'label': guest['label'] as String
                              })
                          .toList(),
                      maxAvatars: 4,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
                if (_task.followers.isNotEmpty) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildAvatarsFollowers(
                        _task.followers
                            .map((follower) => {
                                  'avatar': follower['avatar'] as String?,
                                  'label': follower['label'] as String
                                })
                            .toList(),
                        maxAvatars: 4),
                  ),
                  const SizedBox(height: 5),
                ],
              ],
            ),

            // Level 4
          ],
        ),
      ),
    );
  }
}
