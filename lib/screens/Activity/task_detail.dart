import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/RoomCommenatire.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_task_type.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  const TaskDetailPage({Key? key, required this.taskId}) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Future<Map<String, dynamic>> taskDetails;
  late Future<List<TaskType>> taskTypes;

  @override
  void initState() {
    super.initState();
    taskDetails = getTaskDetails(widget.taskId);
    taskTypes = fetchTaskTypes();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Comments'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: taskDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Failed to load task details: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No task details available'));
            } else {
              Map<String, dynamic> data = snapshot.data!['data'];
              return FutureBuilder<List<TaskType>>(
                future: taskTypes,
                builder: (context, taskTypeSnapshot) {
                  if (taskTypeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (taskTypeSnapshot.hasError) {
                    return Center(
                        child: Text(
                            'Failed to load task types: ${taskTypeSnapshot.error}'));
                  } else if (!taskTypeSnapshot.hasData ||
                      taskTypeSnapshot.data == null) {
                    return const Center(child: Text('No task types available'));
                  } else {
                    return TabBarView(
                      children: [
                        TaskDetailTab(
                            data: data, taskTypes: taskTypeSnapshot.data!),
                        TaskCommentsTab(
                          roomId: data['room_id'] != null
                              ? data['room_id'].toString()
                              : null,
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class TaskDetailTab extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<TaskType> taskTypes;

  TaskDetailTab({required this.data, required this.taskTypes});

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateFormat('dd-MM-yyyy').parse(data['start_date']);
    DateTime endDate = DateFormat('dd-MM-yyyy').parse(data['end_date']);
    String startTime = data['start_time'];
    String endTime = data['end_time'];
    bool isOverdue = data['is_overdue'] ?? false;
    TaskType? taskType = taskTypes.firstWhere(
        (type) => type.id == data['tasks_type_id'],
        orElse: () => TaskType(
            id: 0, label: 'Unknown', color: '#000000', icon: 'help_outline'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Label and Type Icon
          if (data['label'] != null)
            Row(
              children: [
                Icon(_getIconData(taskType.icon),
                    color: _getColorFromHex(taskType.color)),
                const SizedBox(width: 16.0),
                Text(data['label'],
                    style: const TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold)),
              ],
            ),
          const SizedBox(height: 16.0),
          // Owner Avatar and Label
          if (data['owner_id'] != null)
            Row(
              children: [
                _buildAvatar(data['owner_id']['avatar']),
                const SizedBox(width: 16.0),
                Text(data['owner_id']['label'] ?? 'N/A'),
              ],
            ),
          const SizedBox(height: 16.0),
          // Priority
          if (data['priority'] != null)
            _buildDetailRow('Priority', data['priority'] ?? 'N/A',
                color: _getPriorityFlagColor(data['priority'])),
          // Start Date and Time
          if (data['start_date'] != null && data['start_time'] != null)
            _buildDetailRow('Start',
                '${DateFormat('dd-MM-yyyy').format(startDate)} $startTime'),
          // End Date and Time
          if (data['end_date'] != null && data['end_time'] != null)
            _buildDetailRow(
                'End', '${DateFormat('dd-MM-yyyy').format(endDate)} $endTime',
                valueStyle:
                    TextStyle(color: isOverdue ? Colors.red : Colors.black)),
          const SizedBox(height: 16.0),
          // Family
          if (data['family_label'] != null && data['family_label'].isNotEmpty)
            _buildDetailRow('Family', data['family_label'].toString()),
          // Element
          if (data['element_label'] != null && data['element_label'].isNotEmpty)
            _buildDetailRow('Element', data['element_label'].toString()),
          const SizedBox(height: 16.0),
          // Guests
          if (data['guests'] != null && data['guests'].isNotEmpty)
            _buildAvatarsSection('Guests', data['guests']),
          // Followers
          if (data['followers'] != null && data['followers'].isNotEmpty)
            _buildAvatarsSection('Followers', data['followers']),
          const SizedBox(height: 16.0),
          // Description
          if (data['description'] != null && data['description'].isNotEmpty)
            _buildDetailRow('Description', data['description'].toString()),
          // Note
          if (data['note'] != null && data['note'].isNotEmpty)
            _buildDetailRow('Note', data['note'].toString()),
          // Pipeline
          if (data['pipeline_label'] != null)
            _buildDetailRow('Pipeline', data['pipeline_label'].toString()),
          // Stage
          if (data['stage_label'] != null)
            _buildDetailRow('Stage', data['stage_label'].toString()),
          const SizedBox(height: 16.0),
          // Files
          if (data['upload'] != null && (data['upload'] as List).isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Files:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8.0),
                ...data['upload']
                    .map<Widget>((file) => Text(file.toString()))
                    .toList(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {TextStyle? valueStyle, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value,
              style: valueStyle ?? TextStyle(color: color ?? Colors.black)),
        ],
      ),
    );
  }

  Widget _buildAvatarsSection(String label, List<dynamic> people) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8.0),
        _buildAvatars(people),
      ],
    );
  }

  Widget _buildAvatars(List<dynamic> people) {
    List<Widget> avatarWidgets = [];
    for (int i = 0; i < people.length && i < 3; i++) {
      final person = people[i];
      if (person is Map && person.containsKey('avatar')) {
        avatarWidgets.add(Positioned(
            left: i * 20.0, child: _buildAvatar(person['avatar'] ?? "")));
      }
    }
    if (people.length > 3) {
      avatarWidgets.add(Positioned(
          left: 3 * 20.0,
          child:
              CircleAvatar(radius: 15, child: Text('+${people.length - 3}'))));
    }
    return Container(
        width: 80, height: 40, child: Stack(children: avatarWidgets));
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

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  Color _getPriorityFlagColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return Colors.grey;
      case 'medium':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }
}

class TaskCommentsTab extends StatelessWidget {
  final String? roomId;

  TaskCommentsTab({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return roomId == null
        ? const Center(child: Text("No Comment Room Available"))
        : RommCommanitairePage(roomId: roomId!);
  }
}
