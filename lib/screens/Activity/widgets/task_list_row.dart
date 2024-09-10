// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:intl/intl.dart';
import '../../../services/Activities/api_get_stage.dart';
import '../../../services/Activities/api_update_stage_task.dart';
import '../../homeNavigate_page.dart';

class TaskListRow extends StatefulWidget {
  final IconData taskIcon;
  final String taskId;
  final String taskLabel;
  final String ownerLabel;
  final String startDate;
  final String endDate;
  final String endTime;
  final String priority;
  final IconData priorityIcon;
  final Color priorityColor;
  final String? ownerAvatar;
  final String? stageLabel;

  final bool isOverdue;
  final String task_type_color;
  final String start_date;
  final String start_time;
  final int is_follower;
  final int can_update_task;

  const TaskListRow(
      {Key? key,
      required this.taskIcon,
      required this.taskId,
      required this.taskLabel,
      required this.ownerLabel,
      required this.startDate,
      required this.endDate,
      required this.endTime,
      required this.priority,
      required this.priorityIcon,
      required this.priorityColor,
      required this.ownerAvatar,
      required this.stageLabel,
      required this.isOverdue,
      required this.task_type_color,
      required this.start_date,
      required this.start_time,
      required this.can_update_task,
      required this.is_follower})
      : super(key: key);

  @override
  State<TaskListRow> createState() => _TaskListRowState();
}

class _TaskListRowState extends State<TaskListRow> {
  late Future<String> imageUrlFuture;
  List<dynamic> stages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    imageUrlFuture = Config.getApiUrl("urlImage");
    fetchStagesFromApi(); // Fetch stages when the widget initializes
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
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

  Widget _buildAvatar(String? avatar, String ownerLabel, Color color) {
    String initial = ownerLabel.isNotEmpty ? ownerLabel[0].toUpperCase() : '?';

    if (avatar!.isEmpty || avatar.length == 1) {
      return CircleAvatar(
        backgroundColor: color,
        radius: 15,
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white),
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

          if (snapshot.hasError) {
            return CircleAvatar(
              backgroundColor: color,
              radius: 15,
              child: Text(
                initial,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          String baseUrl = snapshot.data ?? "";
          return CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 15,
            child: ClipOval(
              child: Image.network(
                "$baseUrl$avatar",
                fit: BoxFit.cover,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    backgroundColor: color,
                    radius: 15,
                    child: Text(
                      initial,
                      style: TextStyle(color: color),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
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
    Locale currentLocale = Localizations.localeOf(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isDarkMode == false
            ? Color.fromARGB(255, 244, 245, 247)
            : Color.fromARGB(255, 31, 24,
                24), //hexToColor(widget.task_type_color).withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90, // Adjust the height as needed
              child: Container(
                width: 6, // Thickness of the vertical bar
                decoration: BoxDecoration(
                  color: hexToColor(widget.task_type_color)
                      .withOpacity(0.8), // Color of the vertical bar
                  borderRadius: BorderRadius.circular(
                      10), // Adjust the radius for round corners
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              // Use Expanded to control space allocation
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(widget.taskIcon,
                          color: hexToColor(widget.task_type_color)
                              .withOpacity(0.6)),
                      const SizedBox(width: 10),
                      Expanded(
                        // Expand the Text widget to avoid overflow
                        child: Text(
                          widget.taskLabel,
                          style: Theme.of(context).textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.flag,
                        color: _getPriorityColor(widget.priority),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color:
                            hexToColor(widget.task_type_color).withOpacity(0.6),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        // Make the Text expand to fit within Row
                        child: Text(
                          formatDate(widget.start_date, currentLocale) +
                              " " +
                              widget.start_time,
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.white
                                : Color.fromARGB(255, 9, 1, 71),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Stage: ",
                            style: TextStyle(
                              color: hexToColor(widget.task_type_color),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (widget.is_follower == 0) {
                                _showStageDialog(
                                  widget.stageLabel,
                                  widget.taskId,
                                );
                              }
                            },
                            child: Text(
                              widget.stageLabel?.isNotEmpty == true
                                  ? widget.stageLabel!
                                  : "No stage available",
                              style: TextStyle(
                                color: hexToColor(widget.task_type_color),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              width: 130,
                              child: Text(
                                widget.ownerLabel,
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white
                                      : Color.fromARGB(255, 9, 1,
                                          71), // color: hexToColor(widget.task_type_color),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildAvatar(
                              widget.ownerAvatar,
                              widget.ownerLabel,
                              hexToColor(widget.task_type_color),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(String dateString, Locale locale) {
    DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);
    String formattedDate = DateFormat.yMMMMd(locale.languageCode).format(date);
    return formattedDate;
  }

  void _showStageDialog(String? stageLabel, String id) {
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
                  color: hexToColor(widget.task_type_color),
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
              child: Text(
                'Close',
                style: TextStyle(color: Colors.blue),
              ),
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

              // If successful, show a success Snackbar

              // Close the dialog after a successful update

              // Refresh the page
              Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) => HomeNavigate(
                    id_page: 1,
                  ),
                ),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Stage changed successfully',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            } catch (e) {
              // If there is an error, show an error Snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Problem when updating stage',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
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

  Future<void> fetchStagesFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedStages = await fetchStages();
      if (mounted) {
        // Vérifie si le widget est toujours monté
        setState(() {
          stages = fetchedStages;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load stages: $e');
      if (mounted) {
        // Vérifie si le widget est toujours monté
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
