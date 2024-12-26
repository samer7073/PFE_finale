import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../services/sharedPreference.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Modèle de données pour une tâche
class Task {
  final String id;
  final String user;
  final String idData;
  final List<dynamic> action;
  final int read;
  final String createdAt;
  final String userImageUrl;

  Task({
    required this.id,
    required this.user,
    required this.idData,
    required this.action,
    required this.read,
    required this.createdAt,
    required this.userImageUrl,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      user: json['user'],
      idData: json['id_data'],
      action: json['action'],
      read: json['read'],
      createdAt: json['created_at'],
      userImageUrl: json['user_2']['avatar'],
    );
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Task> _tasks = [];
  int _page = 1;
  int _limit = 20;
  bool _isLoading = false;
  bool _hasMoreData = true;

  Future<String>? imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _scrollController.addListener(_onScroll);
    imageUrlFuture = Config.getApiUrl("urlImage");
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _fetchTasks();
      }
    }
  }

  Future<void> _fetchTasks() async {
    if (_isLoading) return;
    _isLoading = true;
    final token = await SharedPrefernce.getToken("token");
    final baseUrl = await Config.getApiUrl("taskNotif");
    final url = baseUrl + "log?page=$_page&limit=$_limit";

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Task> tasks =
          List<Task>.from(data['data'].map((task) => Task.fromJson(task)));

      setState(() {
        if (tasks.length < _limit) {
          _hasMoreData = false;
        }
        _tasks.addAll(tasks);
        _page++;
      });
    } else {
      throw Exception('Failed to load tasks');
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _calculateTimeAgo(String createdAt) {
    final timeAgo = DateTime.parse(createdAt);
    final now = DateTime.now();
    final difference = now.difference(timeAgo);
    log(createdAt);
    log(difference.toString());

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  String _generateNotificationText(List action) {
    if (action.contains('Update_stage')) {
      return '${AppLocalizations.of(context)!.haschangedthestageoftheactivity} ${action[1]}';
    } else if (action.contains('update_priority')) {
      return '${AppLocalizations.of(context)!.hasupdatedthepriorityoftheactivity} ${action[1]}';
    } else if (action.contains('Creation')) {
      return ' ${AppLocalizations.of(context)!.addedyouasParticipantinnewactivity} ${action[1]}';
    } else if (action.contains('Deletion')) {
      return '${AppLocalizations.of(context)!.hasdeletedtheactivity} ${action[1]}';
    } else {
      return ' ${AppLocalizations.of(context)!.hasupdated} ${action[1]}';
    }
  }

  String formatDate(String dateString, Locale locale) {
    DateTime date = DateTime.parse(dateString);
    DateTime now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return DateFormat.Hm(locale.languageCode).format(date);
    }

    if (now.difference(date).inDays < 7) {
      return DateFormat.E(locale.languageCode).format(date);
    }

    return DateFormat('d MMM yyyy HH:MM', locale.languageCode).format(date);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child:
                Text('${AppLocalizations.of(context)!.errorloadingimageurl}'),
          );
        }

        String baseUrll = snapshot.data ?? "";

        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.notifications),
          ),
          body: _isLoading && _tasks.isEmpty
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : _tasks.isEmpty
                  ? Center(
                      child: Text(
                          "${AppLocalizations.of(context)!.therearenonotifications}"),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _tasks.length + (_hasMoreData ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _tasks.length) {
                          // Affichez l'indicateur de chargement à la fin de la liste
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                            ),
                          );
                        }
                        final task = _tasks[index];

                        final formattedDateTime = formatDate(
                            task.createdAt, Localizations.localeOf(context));
                        final notificationText =
                            _generateNotificationText(task.action);

                        return ListTile(
                          leading: task.userImageUrl.length == 1
                              ? CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    task.userImageUrl,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  radius: 20,
                                )
                              : CircleAvatar(
                                  backgroundImage: NetworkImage(
                                      "$baseUrll${task.userImageUrl}"),
                                  radius: 20,
                                ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Nom d'utilisateur avec une largeur fixe
                              Container(
                                width:
                                    120, // Fixez la largeur pour le nom d'utilisateur
                                child: Text(
                                  task.user,
                                ),
                              ),
                              // Date avec une largeur fixe
                              Container(
                                width: 100, // Fixez la largeur pour la date
                                child: Text(
                                  formattedDateTime,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          // La sous-titre flexible s'adapte à l'espace restant
                          subtitle: Text(
                            notificationText,
                            overflow: TextOverflow.ellipsis,
                            maxLines:
                                2, // Limitez le texte à 2 lignes si nécessaire
                          ),
                        );
                      },
                    ),
        );
      },
    );
  }
}
