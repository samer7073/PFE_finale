import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/Activities_views/task_type_icon.dart';
import 'package:flutter_application_stage_project/screens/Activity/chat_room_screen.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  TaskDetailsScreen({required this.task});

  IconData getTaskTypeIcon(int tasks_type_id) {
    switch (tasks_type_id) {
      case 1:
        return iconMap['CalendarOutlined'] ?? Icons.calendar_today;
      case 2:
        return iconMap['MailOutlined'] ?? Icons.mail_outline;
      case 3:
        return iconMap['VideoCameraOutlined'] ?? Icons.videocam;
      case 11:
        return iconMap['WrenchScrewdriverIcon'] ?? Icons.build;
      case 4:
        return iconMap['PhoneOutlined'] ?? Icons.phone;
      case 12:
        return iconMap['BankOutlined'] ?? Icons.account_balance;

      default:
        return iconMap['AtSymbolIcon'] ?? Icons.alternate_email;
    }
  }

  String getInitials(String name) {
    return name.isNotEmpty
        ? name.split(' ').map((word) => word[0]).take(2).join().toUpperCase()
        : '';
  }

  String getTaskTypeName(int tasks_type_id) {
    switch (tasks_type_id) {
      case 1:
        return 'Meeting';
      case 2:
        return 'Email';
      case 3:
        return 'Visio';
      case 11:
        return 'Intervention et service ';
      case 4:
        return 'Call';
      case 12:
        return 'activité test ';

      default:
        return 'test';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              const Text('Activity Details',
                  style: TextStyle(color: Colors.white)),
              const Spacer(),
            ],
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Chat'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskHeader(),
                    const SizedBox(height: 20.0),
                    _buildTaskDetails(),
                    const SizedBox(height: 20.0),
                    _buildTaskParticipants(),
                    const SizedBox(height: 20.0),
                    _buildTaskDates(),
                    const SizedBox(height: 20.0),
                    _buildTaskDescription(),
                    const SizedBox(height: 20.0),
                    _buildTaskAdditionalInfo(),
                  ],
                ),
              ),
            ),
            ChatRoomScreen(task: task),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UpdateTaskScreen(taskId: task.id)),
            );
          },
          child: const Icon(Icons.edit),
          backgroundColor: Colors.purple[100],
        ),
      ),
    );
  }

  Widget _buildTaskHeader() {
    return Row(
      children: [
        Icon(Icons.assignment_rounded, color: Colors.purple[100], size: 40),
        const SizedBox(width: 8),
        Text(
          task.label ?? '',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.flag,
          color: getPriorityColor(task.priority ?? ''),
        ),
        const SizedBox(width: 5.0),
        Text(
          task.priority ?? '',
          style: TextStyle(
            color: getPriorityColor(task.priority ?? ''),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyField('Created at:', '${task.createAt}'),
        _buildReadOnlyField('Task Type:', getTaskTypeName(task.tasksTypeId),
            getTaskTypeIcon(task.tasksTypeId)),
      ],
    );
  }

  Widget _buildTaskParticipants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildParticipantField('Owner', task.ownerAvatar, task.ownerLabel),
        const SizedBox(height: 10),
        _buildParticipantField(
            'Creator', task.creatorAvatar, task.creatorLabel),
      ],
    );
  }

  Widget _buildTaskDates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyField('Date:', '${task.startDate} - ${task.endDate}'),
        _buildReadOnlyField('Time:', '${task.startTime} - ${task.endTime}'),
      ],
    );
  }

  Widget _buildTaskDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.description != null && task.description!.isNotEmpty)
          _buildReadOnlyField('Description:', task.description!),
        if (task.note != null && task.note!.isNotEmpty)
          _buildReadOnlyField('Note:', task.note!),
      ],
    );
  }

  Widget _buildTaskAdditionalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.stageLabel != null)
          _buildReadOnlyField('Corresponding Stage:', task.stageLabel!),
        if (task.pipelineLabel != null)
          _buildReadOnlyField('Corresponding Pipeline:', task.pipelineLabel!),
        if (task.familyLabel != null)
          _buildReadOnlyField('Corresponding Family:', task.familyLabel!),
        if (task.elementLabel != null)
          _buildReadOnlyField('Corresponding Element:', task.elementLabel!),
        _buildReadOnlyField('ID:', '${task.id}'),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, [IconData? icon]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          icon: icon != null ? Icon(icon) : null,
          border: OutlineInputBorder(),
        ),
        enabled: false,
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildParticipantField(String label, String? avatarUrl, String? name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: name,
        decoration: InputDecoration(
          labelText: label,
          icon: avatarUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://spherebackdev.cmk.biz:4543/storage/uploads/$avatarUrl',
                  ),
                )
              : CircleAvatar(
                  child: Text(getInitials(name ?? '')),
                ),
          border: OutlineInputBorder(),
        ),
        enabled: false,
        style: TextStyle(color: Colors.black),
      ),
    );
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
}
