import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/login_page.dart';
import 'package:flutter_application_stage_project/services/ApiTaskKpi.dart';
import '../models/TaskpiModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'error_reporter.dart'; // Importez le gestionnaire d'erreurs

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
    futureApiResponse = ApiTaskKpi.getApiResponse().catchError((error) {
      ErrorReporter.handleError(
          error, context); // Utilisation du gestionnaire d'erreurs
    });
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
              return Center(child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('An error occurred: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              TaskKpiModel? data = snapshot.data;
              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildKpiCard(
                      AppLocalizations.of(context)!.today,
                      data?.today,
                      Icons.today,
                      Color.fromARGB(255, 244, 245, 247),
                      Colors.blue[700],
                      Color.fromARGB(255, 0, 4, 9)),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.thisWeek,
                      data?.thisWeek,
                      Icons.calendar_view_week,
                      Colors.indigo[700],
                      Colors.green[700],
                      Color.fromARGB(255, 0, 6, 1)),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.tomorrow,
                      data?.tomorrow,
                      Icons.calendar_today,
                      Colors.pink[700],
                      Colors.pink[700],
                      const Color.fromARGB(255, 8, 0, 5)),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.upcoming,
                      data?.upcoming,
                      Icons.upcoming,
                      Colors.indigo[700],
                      Colors.orange[700],
                      const Color.fromARGB(255, 10, 4, 0)),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.created,
                      data?.created,
                      Icons.create,
                      Colors.indigo[700],
                      Colors.teal[700],
                      const Color.fromARGB(255, 1, 13, 11)),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.invited,
                      data?.invited,
                      Icons.person_add,
                      Colors.indigo[700],
                      Colors.amber[700],
                      const Color.fromARGB(255, 11, 5, 1)),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.isOverdue,
                      data?.isOverdue,
                      Icons.warning,
                      Colors.indigo[700],
                      Colors.red[700],
                      const Color.fromARGB(255, 17, 3, 3)),
                  _buildKpiCard(
                      AppLocalizations.of(context)!.visio,
                      data?.visio,
                      Icons.video_call,
                      Colors.indigo[700],
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
      color: iconColor?.withOpacity(0.1),
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconColor?.withOpacity(0.7),
                borderRadius: BorderRadius.circular(
                    15), // Optionnel : pour arrondir les coins
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            SizedBox(height: 10.0),
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 05.0),
            Text('$value task', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }
}
