import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:http/http.dart' as http;

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._internal();

  Future<void> initialize(String authToken) async {
    // Initialiser Firebase
    await Firebase.initializeApp();

    // Demander l'autorisation pour les notifications
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log("Notification permission status: ${settings.authorizationStatus}");

    // Récupérer le token APNs si l'appareil est un iOS
    if (Platform.isIOS) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      log("APNs Token: $apnsToken");
    }

    // Récupérer le token FCM
    final token = await FirebaseMessaging.instance.getToken();
    log("FCM Token: $token");

    // Envoyer le token au backend
    if (token != null && authToken.isNotEmpty) {
      await _sendTokenToServer(token, authToken);
    }

    // Écouter les messages reçus au premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("Foreground message: ${message.notification?.title} ${message.notification?.body}");
    });

    // Écouter les mises à jour du token FCM
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      log("Token refreshed: $newToken");
      if (authToken.isNotEmpty) {
        await _sendTokenToServer(newToken, authToken);
      }
    });

    // Gérer les messages reçus en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    log("Message reçu en arrière-plan : ${message.notification?.title} ${message.notification?.body}");
  }

  Future<void> _sendTokenToServer(String fcmToken, String authToken) async {
     final url = await Config.getApiUrl(
        'fcm'); // Utilisation de Config pour obtenir l'URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcm_token': fcmToken}),
      );

      if (response.statusCode == 200) {
        log("FCM Token envoyé avec succès : ${response.body}");
      } else {
        log("Erreur lors de l'envoi du FCM Token : ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      log("Exception lors de l'envoi du FCM Token : $e");
    }
  }
   Future<void> deleteTokenFromServer(String _authToken) async {
  

     final url = await Config.getApiUrl(
        'fcm'); // Utilisation de Config pour obtenir l'URL

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
       
      );

      if (response.statusCode == 200) {
        log("FCM token successfully deleted from server.");
      } else {
        log("Failed to delete FCM token from server. Status code: \${response.statusCode}");
      }
    } catch (e) {
      log("Error deleting FCM token from server: \$e");
    }
  }
}
