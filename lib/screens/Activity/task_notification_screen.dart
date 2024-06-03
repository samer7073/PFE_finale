import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_task_notification.dart';

class TaskLogScreen extends StatefulWidget {
  @override
  _TaskLogScreenState createState() => _TaskLogScreenState();
}

class _TaskLogScreenState extends State<TaskLogScreen> {
  final TaskLogService taskLogService = TaskLogService();
  late Future<Map<String, dynamic>> futureTaskLogs;
  late Future<Map<String, dynamic>> futureNotificationNumbers;

  @override
  void initState() {
    super.initState();
    futureTaskLogs = taskLogService.fetchTaskLogs();
    futureNotificationNumbers = taskLogService.getNotificationNumber();
  }

  Future<void> markLogAsRead(String logId, int taskId, String action) async {
    try {
      final response = await taskLogService.markLogAsRead(logId, taskId, action);
      print('Response: $response');
      // Handle the response as needed
    } catch (e) {
      print('Error: $e');
      // Handle the error as needed
    }
  }

  Future<void> markAllLogsAsRead() async {
    try {
      final response = await taskLogService.markAllLogsAsRead();
      print('Response: $response');
      // Refresh the task logs after marking all as read
      setState(() {
        futureTaskLogs = taskLogService.fetchTaskLogs();
      });
    } catch (e) {
      print('Error: $e');
      // Handle the error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: markAllLogsAsRead,
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: futureNotificationNumbers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final notificationNumbers = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Task Notifications: ${notificationNumbers['task_count']}'),
                      Text('Visio Notifications: ${notificationNumbers['visio_count']}'),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('No data found'));
              }
            },
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: futureTaskLogs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  final taskLogs = snapshot.data!['data'];
                  return ListView.builder(
                    itemCount: taskLogs.length,
                    itemBuilder: (context, index) {
                      final log = taskLogs[index];
                      final logId = log['id'] ?? '';
                      final taskId = log['task_id'] != null ? int.parse(log['task_id']) : 0;
                      final action = log['action'] != null ? log['action'].join(", ") : '';

                      return ListTile(
                        title: Text(action),
                        subtitle: Text('User: ${log['user']} - Created At: ${log['created_at']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            markLogAsRead(logId, taskId, action);
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
