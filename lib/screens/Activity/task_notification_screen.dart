import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_task_notification.dart';

class TaskNotificationScreen extends StatefulWidget {
  @override
  _TaskNotificationScreenState createState() => _TaskNotificationScreenState();
}

class _TaskNotificationScreenState extends State<TaskNotificationScreen> {
  List<dynamic> taskLogs = [];
  int notificationCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTaskLogs();
    fetchNotificationCount();
  }

  Future<void> fetchTaskLogs() async {
    try {
      final logs = await TaskApiService.fetchTaskLogs();
      setState(() {
        taskLogs = logs;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching task logs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchNotificationCount() async {
    try {
      final count = await TaskApiService.fetchNotificationCount();
      setState(() {
        notificationCount = count;
      });
    } catch (e) {
      print('Error fetching notification count: $e');
    }
  }

  Future<void> updateTaskLogRead(String logId, String taskId) async {
    try {
      await TaskApiService.updateTaskLogRead(logId, taskId);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Task log updated successfully'),
      ));
      fetchTaskLogs(); // Refresh the task logs
      fetchNotificationCount(); // Refresh the notification count
    } catch (e) {
      print('Error updating task log: $e');
    }
  }

  Future<void> updateAllTaskLogsRead() async {
    try {
      await TaskApiService.updateAllTaskLogsRead();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('All task logs marked as read'),
      ));
      fetchTaskLogs(); // Refresh the task logs
      fetchNotificationCount(); // Refresh the notification count
    } catch (e) {
      print('Error updating all task logs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () => updateAllTaskLogsRead(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'You have $notificationCount new notifications',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: taskLogs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(taskLogs[index]['type'] ?? 'Unknown Type'),
                        subtitle: Text(taskLogs[index]['message'] ??
                            'No message available'),
                        trailing: IconButton(
                          icon: const Icon(Icons.mark_email_read),
                          onPressed: () => updateTaskLogRead(
                            taskLogs[index]['id'],
                            taskLogs[index]['task_id'],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
