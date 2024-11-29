// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/Activity/comments_room.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_task_type.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/constants/shared/config.dart';

import 'package:html/parser.dart' as html_parser;

class TaskDetailPage extends StatefulWidget {
  final String taskId;
  const TaskDetailPage({Key? key, required this.taskId}) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Future<Map<String, dynamic>> taskDetails;
  late Future<List<TaskType>> taskTypes;
  late String _imageUrl;
late Locale currentLocale; 
  @override
  void initState() {
    super.initState();
    taskDetails = getTaskDetails(widget.taskId);
    taskTypes = fetchTaskTypes();
    _loadImageUrl();
  }

  Future<void> _loadImageUrl() async {
    try {
      _imageUrl = await Config.getApiUrl("urlImage");
      log(_imageUrl + "00000000000000000000000000000000000000");
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            'Failed to load image URL: $e',
            style: TextStyle(color: Colors.white),
          )),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Comments'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: taskDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.blue,
              ));
            } else if (snapshot.hasError) {
              return Center(
                  child:
                      Text('Failed to load task details: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No task details available'));
            } else {
              Map<String, dynamic> data = snapshot.data!['data'];
              return FutureBuilder<List<TaskType>>(
                future: taskTypes,
                builder: (context, taskTypeSnapshot) {
                  if (taskTypeSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.blue,
                    ));
                  } else if (taskTypeSnapshot.hasError) {
                    return Center(
                        child: Text(
                            'Failed to load task types: ${taskTypeSnapshot.error}'));
                  } else if (!taskTypeSnapshot.hasData ||
                      taskTypeSnapshot.data == null) {
                    return const Center(child: Text('No task types available'));
                  } else {
                    return TabBarView(
                      children: [
                        TaskDetailTab(
                          data: data,
                          taskTypes: taskTypeSnapshot.data!,
                          imageUrl: _imageUrl,
                        ),
                        TaskCommentsTab(
                          roomId: data['room_id'] != null
                              ? data['room_id'].toString()
                              : null,
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class TaskDetailTab extends StatelessWidget {
  final Map<String, dynamic> data;
  final List<TaskType> taskTypes;
  final String imageUrl;

  TaskDetailTab(
      {required this.data, required this.taskTypes, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String startDate = data['start_date'];
    String endDate = data['end_date'];
    String startTime = data['start_time'];
    String endTime = data['end_time'];
    bool isOverdue = data['is_overdue'] ?? false;
    TaskType? taskType = taskTypes.firstWhere(
        (type) => type.id == data['tasks_type_id'],
        orElse: () => TaskType(
            id: 0, label: 'Unknown', color: '#000000', icon: 'help_outline'));

    // Initialiser la liste des noms de fichiers
    List<String> fileNames = [];
    if (data['upload'] != null && (data['upload'] as List).isNotEmpty) {
      fileNames = (data['upload'] as List)
          .map((file) => (file as Map<String, dynamic>)['fileName'] as String)
          .toList();
    }
    

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['label'] != null) ...[
            Row(
              children: [
                Icon(
                  _getIconData(taskType.icon),
                  color: _getColorFromHex(taskType.color),
                ),
                const SizedBox(width: 16.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    data['label'],
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
          if (data['owner_id'] != null) ...[
            Row(
              children: [
                _buildAvatar(
                    data['owner_id']['avatar'], data['owner_id']['label']),
                const SizedBox(width: 16.0),
                Text(data['owner_id']['label'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16.0),
          ],
          if (data['priority'] != null) ...[
            _buildDetailRow(
              'Priority',
              data['priority'] ?? 'N/A',
              color: _getPriorityFlagColor(data['priority']),
            ),
          ],
          if (data['stage_label'] != null) ...[
            _buildDetailRow('Stage', data['stage_label'].toString()),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (data['start_date'] != null && data['start_time'] != null) ...[
                _buildDetailRow(
                  'Start',
                  
                  '$startDate  $startTime',
                ),
              ],
              if (data['end_date'] != null && data['end_time'] != null) ...[
                _buildDetailRow(
                  'End',
                  '$endDate $endTime',
                  valueStyle: TextStyle(
                    color: isOverdue ? Colors.red : isDarkMode? Colors.white:Colors.black,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16.0),
          if (data['family_label'] != null &&
              data['family_label'].isNotEmpty) ...[
            _buildDetailRow('Family', data['family_label'].toString()),
          ],
          if (data['element_label'] != null &&
              data['element_label'].isNotEmpty) ...[
            _buildDetailRow('Element', data['element_label'].toString()),
          ],
          const SizedBox(height: 16.0),
          if (data['guests'] != null && data['guests'].isNotEmpty) ...[
            _buildAvatarsSection('Guests', data['guests'], context),
          ],
          if (data['followers'] != null && data['followers'].isNotEmpty) ...[
            _buildAvatarsSection('Followers', data['followers'], context),
          ],
          const SizedBox(height: 16.0),
          if (data['description'] != null &&
              data['description'].isNotEmpty) ...[
            _buildDetailRow(
                'Description', _removeHtmlTags(data['description'].toString())),
          ],
          if (data['note'] != null && data['note'].isNotEmpty) ...[
            _buildDetailRow('Note', _removeHtmlTags(data['note'].toString())),
          ],
          if (data['pipeline_label'] != null) ...[
            _buildDetailRow('Pipeline', data['pipeline_label'].toString()),
          ],
          const SizedBox(height: 16.0),
          if (fileNames.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Files:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                ...fileNames.map<Widget>((fileName) => Text(fileName)).toList(),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {TextStyle? valueStyle, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: valueStyle ?? TextStyle(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarsSection(
    String label,
    List<dynamic> people,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        _buildAvatars(
          people,
        ),
      ],
    );
  }

  Widget _buildAvatars(List<dynamic> people) {
    List<Widget> avatarWidgets = [];
    for (int i = 0; i < people.length; i++) {
      final person = people[i];
      if (person is Map &&
          person.containsKey('avatar') &&
          person.containsKey('label')) {
        final avatar = person['avatar'];
        final label = person['label'];
        avatarWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              verticalOffset: 48,
              height: 50,
              textStyle: TextStyle(color: Colors.white),
              message: label,
              child: _buildAvatar(avatar ?? "", label ?? ""),
            ),
          ),
        );
      }
    }

    return Wrap(
      spacing: 0.0, // Espacement horizontal entre les avatars
      runSpacing: 0.0, // Espacement vertical entre les lignes d'avatars
      children: avatarWidgets,
    );
  }

  Widget _buildAvatar(String avatar, String label) {
    String initial = label.isNotEmpty ? label[0].toUpperCase() : '?';

    if (avatar.isEmpty || avatar.length == 1) {
      // Show the initial of the owner's name if avatar is null or empty
      return CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 15,
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage("$imageUrl/$avatar"),
        radius: 15,
      );
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'WhatsAppOutlined':
        return FontAwesomeIcons.whatsapp;
      case 'WarningOutlined':
        return Icons.warning;
      case 'VideoCameraOutlined':
        return Icons.video_call;
      case 'UserOutlined':
        return Icons.person_outline;
      case 'UploadOutlined':
        return Icons.upload;
      case 'SettingOutlined':
        return Icons.settings;
      case 'ReadOutlined':
        return Icons.read_more_outlined;
      case 'PhoneOutlined':
        return Icons.phone;
      case 'MobileOutlined':
        return Icons.phone_android;
      case 'MessageOutlined':
        return Icons.message;
      case 'MailOutlined':
        return Icons.mail_outline;
      case 'InstagramOutlined':
        return FontAwesomeIcons.instagram;

      case 'InboxOutlined':
        return Icons.inbox_outlined;
      case 'GlobalOutlined':
        return Icons.abc;
      case 'FolderOutlined':
        return Icons.folder_open_outlined;
      case 'FieldTimeOutlined':
        return Icons.access_time;
      case 'FacebookOutlined':
        return Icons.facebook;
      case 'EditOutlined':
        return Icons.edit;
      case 'CreditCardOutlined':
        return Icons.credit_card;
      case 'CommentOutlined':
        return Icons.comment_outlined;
      case 'CheckCircleOutlined':
        return Icons.check_circle_outline;
      case 'CarOutlined':
        return Icons.directions_car_outlined;
      case 'CameraOutlined':
        return Icons.camera_alt_outlined;
      case 'BellOutlined':
        return Icons.notifications_none;
      case 'BankOutlined':
        return Icons.account_balance;
      case 'CalendarOutlined':
        return Icons.calendar_today;
      case 'MailOutlined':
        return Icons.mail_outline;
      case 'VideoCameraOutlined':
        return Icons.videocam_outlined;
      case 'WrenchScrewdriverIcon':
        return Icons.build;
      case 'PhoneOutlined':
        return Icons.phone_outlined;
      case 'BankOutlined':
        return Icons.account_balance;
      case 'AtSymbolIcon':
        return Icons.alternate_email;
      case 'WebOutlined':
        return FontAwesomeIcons.earthAfrica;

      default:
        return Icons.help_outline;
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  Color _getPriorityFlagColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return Colors.grey;
      case 'medium':
        return Colors.blue;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }

  String _removeHtmlTags(String htmlString) {
    final document = html_parser.parse(htmlString);
    return document.body?.text ?? htmlString;
  }
}

class TaskCommentsTab extends StatelessWidget {
  final String? roomId;

  TaskCommentsTab({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return roomId == null
        ?  Center(child: Text(AppLocalizations.of(context)!.nocommentroomavailable))
        : RommCommentairePage(roomId: roomId!);
  }
}
