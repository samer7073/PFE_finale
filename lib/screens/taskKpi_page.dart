import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/services/ApiTaskKpi.dart';
import '../models/TaskpiModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskKpiPage extends StatefulWidget {
  const TaskKpiPage({super.key});

  @override
  State<TaskKpiPage> createState() => _TaskKpiPageState();
}

class _TaskKpiPageState extends State<TaskKpiPage> {
  late Future<TaskKpiModel> futureApiResponse;

  @override
  void initState() {
    super.initState();
    futureApiResponse = ApiTaskKpi.getApiResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<TaskKpiModel>(
          future: futureApiResponse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              TaskKpiModel? data = snapshot.data;
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildKpiCard(
                      AppLocalizations.of(context).today,
                      data?.today,
                      Icons.today,
                      Color.fromARGB(255, 244, 245, 247),
                      Colors.blue[700],
                      Color.fromARGB(255, 0, 4, 9)),
                  _buildKpiCard(
                      AppLocalizations.of(context).thisWeek,
                      data?.thisWeek,
                      Icons.calendar_view_week,
                      Color.fromARGB(255, 244, 245, 247),
                      Colors.green[700],
                      Color.fromARGB(255, 0, 6, 1)),
                  _buildKpiCard(
                      AppLocalizations.of(context).tomorrow,
                      data?.tomorrow,
                      Icons.calendar_today,
                      Color.fromARGB(255, 244, 245, 247),
                      Colors.pink[700],
                      const Color.fromARGB(255, 8, 0, 5)),
                  _buildKpiCard(
                      AppLocalizations.of(context).upcoming,
                      data?.upcoming,
                      Icons.upcoming,
                      Color.fromARGB(255, 244, 245, 247),
                      Colors.orange[700],
                      const Color.fromARGB(255, 10, 4, 0)),
                  _buildKpiCard(
                      AppLocalizations.of(context).created,
                      data?.created,
                      Icons.create,
                      const Color.fromARGB(255, 239, 243, 243),
                      Colors.teal[700],
                      const Color.fromARGB(255, 1, 13, 11)),
                  _buildKpiCard(
                      AppLocalizations.of(context).invited,
                      data?.invited,
                      Icons.person_add,
                      const Color.fromARGB(255, 247, 246, 244),
                      Colors.amber[700],
                      const Color.fromARGB(255, 11, 5, 1)),
                  _buildKpiCard(
                      AppLocalizations.of(context).isOverdue,
                      data?.isOverdue,
                      Icons.warning,
                      Color.fromARGB(255, 244, 245, 247),
                      Colors.red[700],
                      const Color.fromARGB(255, 17, 3, 3)),
                  _buildKpiCard(
                      AppLocalizations.of(context).visio,
                      data?.visio,
                      Icons.video_call,
                      Color.fromARGB(255, 244, 245, 247),
                      Colors.indigo[700],
                      const Color.fromARGB(255, 2, 3, 13)),
                ],
              );
            } else {
              return Center(child: Text('No data available'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, int? value, IconData icon, Color? bgColor,
      Color? iconColor, Color? textColor) {
    return Card(
      //color: bgColor, // Background color for the card
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: iconColor), // Icon color
            SizedBox(height: 16.0),
            Text('$value',
                style: Theme.of(context).textTheme.headlineSmall // Text color

                ),
            SizedBox(height: 8.0),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
