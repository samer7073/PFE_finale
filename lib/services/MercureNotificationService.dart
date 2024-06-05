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
      final jwt = await SharedPrefernce.getToken("jwt");
      print('Retrieved token: $jwt');
      final uuid = await SharedPrefernce.getToken("uuid");
      print('Retrieved uuid: $uuid');

      if (jwt == null) {
        print('Token is null, cannot initialize Mercure');
        return;
      }
      if (uuid == null) {
        print('uuid is null, cannot initialize Mercure');
        return;
      }
      if (uuid != null && jwt != null) {
        _mercure = Mercure(
          url: 'https://spheremercuredev.cmk.biz:4443/.well-known/mercure',
          token: jwt,
          topics: ['/notification/dev/user/$uuid', '/chat/dev/user/232'],
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
      }

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
