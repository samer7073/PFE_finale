import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/services/Activities/api_task_type.dart';

Map<String, IconData> iconMap = {
  'CalendarOutlined': Icons.calendar_today,
  'MailOutlined': Icons.mail_outline,
  'VideoCameraOutlined': Icons.videocam,
  'WrenchScrewdriverIcon': Icons.build,
  'PhoneOutlined': Icons.phone,
  'BankOutlined': Icons.account_balance,
  'AtSymbolIcon': Icons.alternate_email,
};

class TaskTypeSelector extends StatefulWidget {
  final int? initialSelectedId;
  final Function(int, String) onSelected; // Modifiez cette ligne

  TaskTypeSelector({this.initialSelectedId, required this.onSelected});

  @override
  _TaskTypeSelectorState createState() => _TaskTypeSelectorState();
}

class _TaskTypeSelectorState extends State<TaskTypeSelector> {
  int? _selectedTaskTypeId;
  List<TaskType>? taskTypes;

  @override
  void initState() {
    super.initState();
    _selectedTaskTypeId = widget.initialSelectedId;
    fetchTaskTypes().then((types) {
      setState(() {
        taskTypes = types;
      });
    }).catchError((error) {
      print('Failed to load task types: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (taskTypes == null) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: taskTypes!.map((taskType) {
          bool isSelected = _selectedTaskTypeId == taskType.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTaskTypeId = taskType.id;
                      widget.onSelected(taskType.id, taskType.label); // Modifiez cette ligne
                    });
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: isSelected ? Colors.purple[100] : Colors.grey[200],
                    child: Icon(
                      iconMap[taskType.icon] ?? Icons.help_outline,
                      color: Color(int.parse('FF' + taskType.color.substring(1), radix: 16)),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  taskType.label,
                  style: TextStyle(
                    color: isSelected ? Colors.purple[100] : Colors.black,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
