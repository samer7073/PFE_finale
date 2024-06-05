import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import '../services/sharedPreference.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchTasks();
    _scrollController.addListener(_onScroll);
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

    final response = await http.get(
      Uri.parse(
          'https://spherebackdev.cmk.biz:4543/api/mobile/tasks/log?page=$_page&limit=$_limit'),
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
      return 'has changed the stage of the activity ${action[1]}';
    } else if (action.contains('update_priority')) {
      return 'has updated the priority of the activity ${action[1]}';
    } else if (action.contains('Creation')) {
      return ' added you as Participant in new activity ${action[1]}';
    } else if (action.contains('Deletion')) {
      return 'has has deleted the activity ${action[1]}';
    } else {
      return ' has updated ${action[1]}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _tasks.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _tasks.length) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final task = _tasks[index];
          final timeAgo = DateTime.parse(task.createdAt);
          final formattedDateTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(timeAgo);
          final notificationText = _generateNotificationText(task.action);

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://spherebackdev.cmk.biz:4543/storage/uploads/${task.userImageUrl}"),
              radius: 25,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(task.user),
                Text(
                  '$formattedDateTime',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            subtitle: Text(notificationText),
          );
        },
      ),
    );
  }
}
