import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart'; // Assurez-vous d'importer correctement SharedPreferences
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class MyHomePageDDD extends StatefulWidget {
  @override
  _MyHomePageDDDState createState() => _MyHomePageDDDState();
}

class _MyHomePageDDDState extends State<MyHomePageDDD> {
  late String jwtToken;
  final url = 'https://spheremercuredev.cmk.biz:4443/.well-known/mercure';
  final topics = [
    '/chat/dev/user/422',
    '/notification/dev/user/9bd65c0d-8b1c-4a4a-9c1a-2ed56e6c5776'
  ];

  late WebSocketChannel channel;
  late Stream<Map<String, dynamic>> eventStream;
  List<Map<String, dynamic>> events = [];

  @override
  void initState() {
    super.initState();
    getToken();
  }

  Future<void> getToken() async {
    jwtToken = (await SharedPrefernce.getToken("token"))!;
    connectToMercure();
  }

  Future<void> connectToMercure() async {
    try {
      final channel = await connectToMercureSocket(url, jwtToken);
      setState(() {
        this.channel = channel;
        eventStream = listenForEvents(channel);
      });

      eventStream.listen((event) {
        setState(() {
          events.add(event);
        });
        print('Événement reçu: $event');
      });
    } catch (error) {
      print('Erreur: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Récupération d\'événements Mercure'),
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text('Topic: ${event['topic']}'),
            subtitle: Text('Données: ${event['data']}'),
          );
        },
      ),
    );
  }
}

Future<WebSocketChannel> connectToMercureSocket(
    String url, String jwtToken) async {
  // Préparez les en-têtes avec l'autorisation
  final headers = {'Authorization': 'Bearer $jwtToken'};
  log('hellllo');

  // Faites une requête GET pour établir la connexion
  final response = await http.get(Uri.parse(url), headers: headers);
  log(response.body.toString());

  if (response.statusCode != 200) {
    throw Exception('Échec de la connexion à Mercure: ${response.statusCode}');
  }

  // Extrayez l'URL du websocket de la réponse
  final websocketUrl = response.headers['link'];
  log("URL du websocket: $websocketUrl");
  if (websocketUrl == null) {
    throw Exception(
        'Impossible de trouver l\'URL du websocket dans la réponse');
  }

  // Connectez-vous au websocket
  return IOWebSocketChannel.connect(websocketUrl);
}

Stream<Map<String, dynamic>> listenForEvents(WebSocketChannel channel) {
  return channel.stream.map((message) {
    print('Message JSON reçu: $message');
    return jsonDecode(message);
  });
}
