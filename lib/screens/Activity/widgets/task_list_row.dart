// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:intl/intl.dart';

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
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap; // Add onTap callback
  final bool isOverdue;
  final String task_type_color;
  final String start_date;
  final String start_time;

  const TaskListRow({
    Key? key,
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
    required this.onDelete,
    required this.onEdit,
    required this.onTap, // Add onTap callback
    required this.isOverdue,
    required this.task_type_color,
    required this.start_date,
    required this.start_time,
  }) : super(key: key);

  @override
  State<TaskListRow> createState() => _TaskListRowState();
}

class _TaskListRowState extends State<TaskListRow> {
  Future<String> _getImageUrl() async {
    return await Config.getApiUrl("urlImage");
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAvatar(String? avatar, String ownerLabel, Color color) {
    String initial = ownerLabel.isNotEmpty ? ownerLabel[0].toUpperCase() : '?';

    if (avatar!.isEmpty || avatar.length == 1) {
      // Show the initial of the owner's name if avatar is null or empty
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
              child: CircularProgressIndicator(),
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

  @override
  void initState() {
    super.initState();
    imageUrlFuture = Config.getApiUrl("urlImage");
  }

  late Future<String> imageUrlFuture;
  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);

    return Container(
      margin: const EdgeInsets.all(8.0), // Add margin
      decoration: BoxDecoration(
        color: hexToColor(widget.task_type_color).withOpacity(0.07),
        borderRadius: BorderRadius.circular(10), // Circular border radius
      ),
      child: GestureDetector(
        onTap: widget.onTap, // Call onTap when the row is tapped
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Slidable(
            key: ValueKey(widget.taskId),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => widget.onEdit(),
                  backgroundColor: Colors.green.withOpacity(0.1),
                  foregroundColor: Colors.green,
                  icon: Icons.edit,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (context) => widget.onDelete(),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  icon: Icons.delete,
                  label: 'Delete',
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(widget.taskIcon,
                            color: hexToColor(widget.task_type_color)
                                .withOpacity(0.6)),
                        const SizedBox(width: 10),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            widget.taskLabel,
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      formatDate(widget.start_date, currentLocale) +
                          " " +
                          widget.start_time,
                      style: TextStyle(color: Color.fromARGB(255, 9, 1, 71)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text("Stage: ",
                            style: TextStyle(
                                color: hexToColor(widget.task_type_color),
                                fontWeight: FontWeight.w600)),
                        Text(
                            widget.stageLabel?.isNotEmpty == true
                                ? widget.stageLabel!
                                : "No stage available",
                            style: TextStyle(
                                color: hexToColor(widget.task_type_color),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(widget.ownerLabel,
                            style: TextStyle(
                                color: hexToColor(widget.task_type_color))),
                        const SizedBox(width: 10),
                        _buildAvatar(widget.ownerAvatar, widget.ownerLabel,
                            hexToColor(widget.task_type_color)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String formatDate(String dateString, Locale locale) {
    // Parse the input date string
    DateTime date = DateFormat('dd-MM-yyyy').parse(dateString);

    // Format the date according to the locale
    String formattedDate = DateFormat.yMMMMd(locale.languageCode).format(date);

    return formattedDate;
  }
}
