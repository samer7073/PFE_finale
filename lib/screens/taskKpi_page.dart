import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/screens/Activity/update_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_calendar_view.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:flutter_application_stage_project/services/ApiTaskKpi.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../models/TaskpiModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'error_reporter.dart';
import 'TaskListPage.dart'; // Importez le gestionnaire d'erreurs

class TaskKpiPage extends StatefulWidget {
  const TaskKpiPage({super.key});

  @override
  State<TaskKpiPage> createState() => TaskKpiPageState();
}

class TaskKpiPageState extends State<TaskKpiPage> {
  late Future<TaskKpiModel> futureApiResponse;
  late Future<List<Task>> futureApiResponsee;
  ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);


  @override
  void initState() {
    super.initState();
    futureApiResponse = ApiTaskKpi.getApiResponse( DateFormat('yyyy-MM-dd').format(DateTime.now()), DateFormat('yyyy-MM-dd').format(DateTime.now())).catchError((error) {
      ErrorReporter.handleError(
          error, context); // Utilisation du gestionnaire d'erreurs
    });
    // Ajouter un écouteur pour détecter les mises à jour
  refreshNotifier.addListener(_refreshData);

  }
  void _refreshData() {
  if (refreshNotifier.value) {
    setState(() {
      futureApiResponse = ApiTaskKpi.getApiResponse(
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
          DateFormat('yyyy-MM-dd').format(DateTime.now()));
      futureApiResponsee = fetchTasks(
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
          DateFormat('yyyy-MM-dd').format(DateTime.now()));
    });
    refreshNotifier.value = false; // Réinitialiser l'état après mise à jour
  }
}

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Map<String, IconData> iconMap = {
    'BankOutlined': Icons.account_balance,
    'BellOutlined': Icons.notifications_outlined,
    'CalendarOutlined': Icons.calendar_today,
    'CameraOutlined': Icons.camera_alt_outlined,
    'CarOutlined': Icons.directions_car_outlined,
    'CheckCircleOutlined': Icons.check_circle_outline,
    'CommentOutlined': Icons.comment_outlined,
    'CreditCardOutlined': Icons.credit_card_outlined,
    'EditOutlined': Icons.edit_outlined,
    'FacebookOutlined': FontAwesomeIcons.facebook,
    'FieldTimeOutlined': Icons.access_time,
    'FolderOutlined': Icons.folder_outlined,
    'GlobalOutlined': Icons.language,
    'InboxOutlined': Icons.inbox_outlined,
    'InstagramOutlined': FontAwesomeIcons.instagram,
    'MailOutlined': Icons.mail_outline,
    'MessageOutlined': Icons.message_outlined,
    'MobileOutlined': Icons.smartphone_outlined,
    'PhoneOutlined': Icons.phone_outlined,
    'ReadOutlined': Icons.book_outlined,
    'SettingOutlined': Icons.settings_outlined,
    'UploadOutlined': Icons.cloud_upload_outlined,
    'UserOutlined': Icons.person_outline,
    'VideoCameraOutlined': Icons.videocam_outlined,
    'WarningOutlined': Icons.warning_outlined,
    'WhatsAppOutlined': FontAwesomeIcons.whatsapp,
    'WrenchScrewdriverIcon':
        FontAwesomeIcons.screwdriverWrench, // Icône pour WrenchScrewdriver
    'AtSymbolIcon': Icons.alternate_email_outlined,
    'WebOutlined': FontAwesomeIcons.earthAfrica,
  };
  IconData _getIconData(String taskTypeIcon) {
    return iconMap[taskTypeIcon] ?? Icons.help_outline;
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent':
        return Icons.flag;
      case 'high':
        return Icons.outlined_flag;
      case 'medium':
        return Icons.flag_outlined;
      case 'low':
        return Icons.flag_outlined;
      default:
        return Icons.flag_outlined;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  void _navigateToDetail(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailPage(taskId: task.id),
      ),
    );
  }

  Future<void> _deleteTask(String taskId, List<Task> tasks) async {
    try {
      await deleteTasks(taskId);
      if (!mounted) return;
      setState(() {
        tasks.removeWhere((task) => task.id == taskId);
      });
    } catch (e) {
      _handleDeleteError(e);
    }
  }

  void _handleDeleteError(dynamic error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to delete task: $error',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _editTask(Task task, String start, String end) async {
    // Naviguer vers la page de mise à jour et récupérer le résultat
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(taskId: task.id),
      ),
    );

    // Si la tâche a été mise à jour (le résultat est true)
    if (updatedTask == true) {
      setState(() {
        // Rafraîchir les tâches filtrées après la mise à jour
        futureApiResponsee =
            fetchTasks(start, end); // Mise à jour de la liste des tâches
      });
    }
  }

  Future<void> afficherTasks(String title, String start, String end,{int? roles,int? type_task,int? isoverdue}) async {
    // Naviguer vers la page de mise à jour et récupérer le résultat
    final updatedTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskListPage(
          title: title, // Titre de la page
          start: start, // Exemple de date de début
          end: end, // Exemple de date de fin
          roles: roles,
          type_task: type_task,
          overdue: isoverdue,
        ),
      ),
    );

    // Si la tâche a été mise à jour (le résultat est true)
    if (updatedTask == true) {
      setState(() {
        // Rafraîchir les tâches filtrées après la mise à jour
         futureApiResponse = ApiTaskKpi.getApiResponse( DateFormat('yyyy-MM-dd').format(DateTime.now()), DateFormat('yyyy-MM-dd').format(DateTime.now()));
        
      });
    }
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
              return Center(
                  child: CircularProgressIndicator(
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
                    Color.fromARGB(255, 0, 4, 9),
                    DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de début
                    DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de fin
                  ),
                  _buildKpiCard(
                    AppLocalizations.of(context)!.thisWeek,
                    data?.thisWeek,
                    Icons.calendar_view_week,
                    Colors.indigo[700],
                    Colors.green[700],
                    Color.fromARGB(255, 0, 6, 1),
                    DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(
                        Duration(
                            days: DateTime.now().weekday %
                                7))), // Exemple de date de début
                    DateFormat('yyyy-MM-dd').format(
                      DateTime.now()
                          .subtract(Duration(days: DateTime.now().weekday % 7))
                          .add(Duration(days: 6)),
                    ), // Exemple de date de fin
                  ),
                  _buildKpiCard(
                    AppLocalizations.of(context)!.tomorrow,
                    data?.tomorrow,
                    Icons.calendar_today,
                    Colors.pink[700],
                    Colors.pink[700],
                    const Color.fromARGB(255, 8, 0, 5),
                    DateFormat('yyyy-MM-dd').format(DateTime.now()
                        .add(Duration(days: 1))), // Exemple de date de début
                    DateFormat('yyyy-MM-dd').format(DateTime.now()
                        .add(Duration(days: 1))), // Exemple de date de fin
                  ),
                  _buildKpiCard(
                    AppLocalizations.of(context)!.upcoming,
                    data?.upcoming,
                    Icons.upcoming,
                    Colors.indigo[700],
                    Colors.orange[700],
                    const Color.fromARGB(255, 10, 4, 0),
                    DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de début
                    DateFormat('yyyy-MM-dd')
                        .format(DateTime.now().add(Duration(days: 7))), // Exemple de date de fin
                  ),
                  _buildKpiCard(
                    AppLocalizations.of(context)!.created,
                    data?.created,
                    Icons.create,
                    Colors.indigo[700],
                    Colors.teal[700],
                    const Color.fromARGB(255, 1, 13, 11),
                     DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de début
                    DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de fin
                    roles: 0,
                  ),
                  _buildKpiCard(
                    AppLocalizations.of(context)!.invited,
                    data?.invited,
                    Icons.person_add,
                    Colors.indigo[700],
                    Colors.amber[700],
                    const Color.fromARGB(255, 11, 5, 1),
                     DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de début
                    DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de fin
                        roles: 2
                  ),
                  _buildKpiCard(
                    AppLocalizations.of(context)!.isOverdue,
                    data?.isOverdue,
                    Icons.warning,
                    Colors.indigo[700],
                    Colors.red[700],
                    const Color.fromARGB(255, 17, 3, 3),
                     DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de début
                    DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de fin
                        isoverdue: 1
                  ),
                  _buildKpiCard(
                    AppLocalizations.of(context)!.visio,
                    data?.visio,
                    Icons.video_call,
                    Colors.indigo[700],
                    Colors.indigo[700],
                    const Color.fromARGB(255, 2, 3, 13),
                     DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de début
                   DateFormat('yyyy-MM-dd')
                        .format(DateTime.now()), // Exemple de date de fin
                        type_task: 3
                  ),
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
      Color? iconColor, Color? textColor, String start, String end,{int? roles,int? type_task,int? isoverdue}) {
    return GestureDetector(
      onTap: () {
       
            afficherTasks(title, start, end,roles: roles,type_task: type_task,isoverdue: isoverdue);
      },
      child: Card(
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
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 10.0),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 5.0),
              Text('$value task',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
