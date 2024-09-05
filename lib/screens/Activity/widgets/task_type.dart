import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/services/Activities/api_task_type.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Map<String, IconData> iconMap = {
  'BankOutlined': Icons.account_balance,
  'BellOutlined': Icons.notifications_none, // Choisissez l'icône appropriée
  'CalendarOutlined': Icons.calendar_today,
  'CameraOutlined': Icons.camera_alt, // Choisissez l'icône appropriée
  'CarOutlined': Icons.directions_car, // Choisissez l'icône appropriée
  'CheckCircleOutlined': Icons.check_circle_outline,
  'CommentOutlined': Icons.comment_outlined, // Choisissez l'icône appropriée
  'CreditCardOutlined':
      Icons.credit_card_outlined, // Choisissez l'icône appropriée
  'EditOutlined': Icons.edit_outlined,
  'FacebookOutlined': FontAwesomeIcons.facebook, // Icône Facebook FontAwesome
  'FieldTimeOutlined': Icons.access_time, // Choisissez l'icône appropriée
  'FolderOutlined': Icons.folder_outlined,
  'GlobalOutlined': Icons.public, // Choisissez l'icône appropriée
  'InboxOutlined': Icons.inbox, // Choisissez l'icône appropriée
  'InstagramOutlined':
      FontAwesomeIcons.instagram, // Icône Instagram FontAwesome
  'MailOutlined': Icons.mail_outline,
  'MessageOutlined': Icons.message_outlined, // Choisissez l'icône appropriée
  'MobileOutlined': Icons.phone_iphone, // Choisissez l'icône appropriée
  'PhoneOutlined': Icons.phone,
  'ReadOutlined': Icons.read_more, // Choisissez l'icône appropriée
  'SettingOutlined': Icons.settings_outlined,
  'UploadOutlined': Icons.upload_outlined, // Choisissez l'icône appropriée
  'UserOutlined': Icons.person_outline, // Choisissez l'icône appropriée
  'VideoCameraOutlined': Icons.videocam,
  'WarningOutlined':
      Icons.warning_amber_outlined, // Choisissez l'icône appropriée
  'WhatsAppOutlined': FontAwesomeIcons.whatsapp, // Icône WhatsApp FontAwesome
  'WrenchScrewdriverIcon':
      FontAwesomeIcons.screwdriverWrench, // Icône pour WrenchScrewdriver
  'AtSymbolIcon': Icons.alternate_email_outlined,
  'WebOutlined':FontAwesomeIcons.earthAfrica,
};

class TaskTypeSelector extends StatefulWidget {
  final int? initialSelectedId;
  final Function(int, String) onSelected;

  const TaskTypeSelector(
      {super.key, this.initialSelectedId, required this.onSelected});

  @override
  // ignore: library_private_types_in_public_api
  _TaskTypeSelectorState createState() => _TaskTypeSelectorState();
}

class _TaskTypeSelectorState extends State<TaskTypeSelector> {
  int? _selectedTaskTypeId;
  List<TaskType>? taskTypes = []; // Initialize with an empty list

  @override
  void initState() {
    super.initState();
    _selectedTaskTypeId = widget.initialSelectedId;
    fetchTaskTypes().then((types) {
      setState(() {
        taskTypes = types;
      });
    }).catchError((error) {
      print('Failed to load task types hhh: $error');
    });
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context) {
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
                      widget.onSelected(taskType.id, taskType.label);
                    });
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: hexToColor(taskType.color).withOpacity(0.8),
                      borderRadius:
                          BorderRadius.circular(10), // Circular border radius
                    ),
                    child: Icon(
                      iconMap[taskType.icon] ?? Icons.help_outline,
                      color: Colors.white,
                      size: 30,
                    ),
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
