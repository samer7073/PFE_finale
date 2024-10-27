import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
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

  MercureNotificationService._internal();

  Future<void> initialize() async {
    await _initializeNotifications();
    await _initializeMercure();
  }

  Future<void> _initializeNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_stat_logo_cmk');
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
      log('Initializing Mercure...');
      final jwt = await SharedPrefernce.getToken("jwt");
      log('Retrieved token jwt: $jwt');
      final uuid = await SharedPrefernce.getToken("uuid");
      log('Retrieved uuid: $uuid');

      if (jwt == null) {
        print('Token is null, cannot initialize Mercure');
        return;
      }
      if (uuid == null) {
        print('UUID is null, cannot initialize Mercure');
        return;
      }

      final topic = await Config.getApiUrl("notifTopic");
      log("Topic: $topic");

      _mercure = Mercure(
        url: await Config.getApiUrl("mercure"),
        token: jwt,
        topics: ['$topic$uuid'],
      );

      log(_mercure.isBroadcast.toString() + " - Mercure is broadcast stream");

      // Cancel any existing subscription before creating a new one
      _subscription?.cancel();
      _subscription = _mercure.listen((event) {
        var eventData = jsonDecode(event.data);
        log("Mercure Event ${eventData['type_event']}");

        if ([
          'new_task',
          'update_priority_task',
          'update_stage_task',
          'update_task',
          'delete_task',
          'message_rmc'
        ].contains(eventData['type_event'])) {
          log('Received relevant event: ${event.data}');

          String title = eventData['type_event'].replaceAll('_', ' ');
          String initiatorName = "";

          switch (eventData['type_event']) {
            case "new_task":
              initiatorName = "${eventData['initiator']['label']} created a new task";
              break;
            case "update_task":
              initiatorName = "${eventData['initiator']['label']} updated ${eventData['label']}";
              break;
            case "delete_task":
              initiatorName = "${eventData['initiator']['label']} deleted the task";
              break;
            case "update_stage_task":
              initiatorName = "${eventData['initiator']['label']} changed the stage to ${eventData['action'][1]}";
              break;
            case "update_priority_task":
              initiatorName = "${eventData['initiator']['label']} updated the priority to ${eventData['action'][1]}";
              break;
            case "message_rmc":
              // For message_rmc event, display the message content in the notification
              initiatorName = eventData['message']; // Get the message content
              break;
          }

          _showNotification(title, initiatorName);
        }
      });

      print('Mercure connection established');
    } catch (error) {
      print('Error initializing Mercure: $error');
    }
  }

  Future<void> _showNotification(String title, String description) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
    );
    const iOSDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin
        .show(0, title, description, notificationDetails)
        .then((value) => print('Notification shown successfully'))
        .catchError((error) => print('Error showing notification: $error'));
  }

  void _handleNotificationResponse(
      BuildContext context, NotificationResponse response) {
    Navigator.pushNamed(context, '/home');
  }

  void dispose() {
    _subscription?.cancel(); // Cancel the subscription when disposing
  }
}
