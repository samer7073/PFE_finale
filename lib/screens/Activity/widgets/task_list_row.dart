import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';

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

  Widget _buildAvatar(String? avatar, String ownerLabel) {
    if (avatar == null || avatar.length == 1) {
      // Show the initial of the owner's name if avatar is null or empty
      String initial =
          ownerLabel.isNotEmpty ? ownerLabel[0].toUpperCase() : '?';
      return CircleAvatar(
        backgroundColor: Colors.blue,
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
              backgroundColor: Colors.blue,
              radius: 15,
              child: Text(
                ownerLabel.isNotEmpty ? ownerLabel[0].toUpperCase() : '?',
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
                    backgroundColor: Colors.blue,
                    radius: 15,
                    child: Text(
                      ownerLabel.isNotEmpty ? ownerLabel[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                      Icon(widget.taskIcon, color: Colors.teal.shade700),
                      const SizedBox(width: 10),
                      Text(
                        widget.taskLabel,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'End: ${widget.endDate} ${widget.endTime}',
                    style: TextStyle(
                      color: widget.isOverdue
                          ? Colors.red
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize:
                          Theme.of(context).textTheme.bodyMedium?.fontSize,
                      fontWeight:
                          Theme.of(context).textTheme.bodyMedium?.fontWeight,
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
                      Text("Stage: ",
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        widget.stageLabel?.isNotEmpty == true
                            ? widget.stageLabel!
                            : "No stage available",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(widget.ownerLabel,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(width: 10),
                      _buildAvatar(widget.ownerAvatar, widget.ownerLabel),
                    ],
                  ),
                ],
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
