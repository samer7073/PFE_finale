import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/services/Activities/api_filter_tasks.dart';

class FilteredTaskListScreen extends StatelessWidget {
  final String? priority;
  final String? label;
  final String? tasksTypeId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? familyLabel;

  const FilteredTaskListScreen({
    Key? key,
    this.priority,
    this.label,
    this.tasksTypeId,
    this.startDate,
    this.endDate,
    this.familyLabel,
  }) : super(key: key);

  Future<List<Task>> fetchFilteredTasks() async {
    return filterTasks(
      priority: priority,
      label: label,
      tasksTypeId: tasksTypeId,
      startDate: startDate,
      endDate: endDate,
      familyLabel: familyLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtered Tasks'),
      ),
      body: FutureBuilder<List<Task>>(
        future: fetchFilteredTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found'));
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://spherebackdev.cmk.biz:4543/storage/uploads/${task.ownerAvatar}',
                      ),
                    ),
                    title: Text(task.label),
                    subtitle: Text(
                        'Start: ${task.startDate} ${task.startTime}\nEnd: ${task.endDate} ${task.endTime}'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailsScreen(task: task),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
