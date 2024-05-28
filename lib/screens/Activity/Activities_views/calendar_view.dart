import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_card.dart';
import 'package:flutter_application_stage_project/services/Activities/api_calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendarviewpage extends StatefulWidget {
  const Calendarviewpage({super.key});

  @override
  _CalendarviewpageState createState() => _CalendarviewpageState();
}

class _CalendarviewpageState extends State<Calendarviewpage> {
////////////////////initialisation//////////////////////////
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<Task> _tasks = [];

  void _removeTask(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 204, 247),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            /////////////////////////////////////Calendar////////////////////////////////////
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                final start = DateFormat('yyyy-MM-dd').format(_selectedDay);
                final end = DateFormat('yyyy-MM-dd').format(_selectedDay);
                final tasks = await fetchTasks(start, end);
                setState(() {
                  _tasks = tasks;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            ///////////////////////////////////Display Activities cards//////////////////////////////
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'No Tasks For Today',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.purple,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return TaskCard(
                          task: task,
                          onDelete:
                              _removeTask, // Pass the remove function to TaskCard
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
