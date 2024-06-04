import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mercure_client/mercure_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sharedPreference.dart';

class MercureNotificationService {
  late Mercure _mercure;
  StreamSubscription? _subscription;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  static final MercureNotificationService _instance =
      MercureNotificationService._internal();

  factory MercureNotificationService() {
    return _instance;
  }
  @override
  MercureNotificationService._internal();

  Future<void> initialize() async {
    await _initializeNotifications();
    await _initializeMercure();
  }

  Future<void> _initializeNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    final result = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        // handle your notification response here
      },
    );

    if (result == true) {
      print('Notification initialization successful');
    } else {
      print('Notification initialization failed');
    }

    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    const androidChannel = AndroidNotificationChannel(
      'channel_id',
      'channel_name',
      description: 'channel_description',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _initializeMercure() async {
    try {
      print('Initializing Mercure...');
      final token = await SharedPrefernce.getToken("token");
      print('Retrieved token: $token');

      if (token == null) {
        print('Token is null, cannot initialize Mercure');
        return;
      }

      _mercure = Mercure(
        url: 'https://spheremercuredev.cmk.biz:4443/.well-known/mercure',
        token:
            "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJtZXJjdXJlIjp7InN1YnNjcmliZSI6WyIvY2hhdC9kZXYvdXNlci80MjIiLCIvbm90aWZpY2F0aW9uL2Rldi91c2VyLzliZDY1YzBkLThiMWMtNGE0YS05YzFhLTJlZDU2ZTZjNTc3NiIsIi8ud2VsbC1rbm93bi9tZXJjdXJlL3N1YnNjcmlwdGlvbnMve3RvcGljfXsvc3Vic2NyaWJlcn0iXSwicGF5bG9hZCI6eyJ1c2VyX3VpZCI6IjliZDY1YzBkLThiMWMtNGE0YS05YzFhLTJlZDU2ZTZjNTc3NiIsImRhdGV0aW1lIjoiMjAyNC0wNi0wM1QxNTo1ODo1Ni4wMzI5OTlaIn19fQ.VA2LYoy24WnDM6nEXue3z2do3XKV5ID3gY6WIgdjJryUII9fIEketOfZpoLtiSn4c8czbtkZI5teflm6lz01xxQAtroNNy6YOTuLFowSxOUQU1NhvpBWDZGLprWzImggmZtOe9LFikjvwSg-rFU5202TMaGYZSihhTNMMhmoyURHJdXxQUSd_29jUt_eJe5zkwrOi1ikoVhN6GIme6_JWb0XCyspOwDiM4byymlB_iZJOlQtbSM_nTBm3RMlnJ_6tPBNoCBgfMIMbHaebfNjs3u7aRxfnOabJdf4PW5Hu2vPC3rUvEcShZ3ZOhGQM2MsiHpepRBEL7akSDLwpTbpsSjNzjQN0pXH5qD9-IYMSfpKnmEOwY4Q9QmD2iyMcIFFEq1wpWBYtan5ZzEeiRbN9-8BIRWqrGnqMYNcx1mjTGddYH9pUWe2UAOl33SGOpjpTZ66C1QXvA_NynZVZpyVDo3Q7yaXnJp4xCtyH9HU52aSQ0wdBGQhXPpvmTUkLA5zE9Q5kxz2-Y5doQ91QOI_Q0HWcJN4SFOTaY6fTB1fGC-3VkuYAU_rrlr8xfPbIhq9SLuBa9u8RCnM9cwX8ORBGPXLiFvpiE8mo-yM_O0S-QUaKFnisQZQ5p_wEJNd0l9s_z633ZAbItdm0-gLqAPVLM2hEV150dJXy243bG5BuZA",
        topics: [
          '/chat/dev/user/422',
          '/notification/dev/user/9bd65c0d-8b1c-4a4a-9c1a-2ed56e6c5776'
        ],
      );

      _subscription = _mercure.listen((event) {
        var eventData = jsonDecode(event.data);
        log("**************************** ${eventData['type_event']}");
        if ([
          'new_task',
          'update_priority_task',
          'update_stage_task',
          'update_task',
          'delete_task'
        ].contains(eventData['type_event'])) {
          print('Received relevant event: ${event.data}');

          if (eventData['type_event'] == "new_task") {
            String title = eventData['type_event'].replaceAll('_', ' ');
            String initiatorName =
                "${eventData['initiator']['label']} create new task";
            _showNotification(title, initiatorName);
          }
          if (eventData['type_event'] == "update_task") {
            String title = eventData['type_event'].replaceAll('_', ' ');
            String initiatorName =
                "${eventData['initiator']['label']} ${eventData['action']} ${eventData['label']}  ";
            _showNotification(title, initiatorName);
          }
          if (eventData['type_event'] == "delete_task") {
            String title = eventData['type_event'].replaceAll('_', ' ');
            String initiatorName =
                "${eventData['initiator']['label']} ${eventData['action'][0]} ${eventData['action'][1]}   ";
            _showNotification(title, initiatorName);
          }
          if (eventData['type_event'] == "update_stage_task") {
            String title = eventData['type_event'].replaceAll('_', ' ');
            String initiatorName =
                "${eventData['initiator']['label']} has changed the stage of the activity  ${eventData['action'][1]} ";
            _showNotification(title, initiatorName);
          }
          if (eventData['type_event'] == "update_priority_task") {
            String title = eventData['type_event'].replaceAll('_', ' ');
            String initiatorName =
                "${eventData['initiator']['label']} updated the priority of the activity  ${eventData['action'][1]} ";
            _showNotification(title, initiatorName);
          }
        }
      });
      print('Mercure connection established');
    } catch (error) {
      print('Error initializing Mercure: $error');
    }
  }

  Future<void> _showNotification(String title, String decription) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const iOSDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin
        .show(
          0,
          title,
          decription,
          notificationDetails,
        )
        .then((value) => print('Notification shown successfully'))
        .catchError((error) => print('Error showing notification: $error'));
  }

  void _handleNotificationResponse(
      BuildContext context, NotificationResponse response) {
    // Utilisez le BuildContext pour naviguer vers la page d'accueil
    Navigator.pushNamed(context, '/home');
  }

  void dispose() {
    _subscription?.cancel();
  }
}
