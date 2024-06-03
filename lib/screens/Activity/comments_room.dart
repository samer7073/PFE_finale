import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/commanitaireRoom/Message.dart';
import 'package:flutter_application_stage_project/models/commanitaireRoom/ResponeRoom.dart';
import 'package:flutter_application_stage_project/services/sharedPreference.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class RommCommentairePage extends StatefulWidget {
  final String roomId;
  const RommCommentairePage({Key? key, required this.roomId})
      : super(key: key);

  @override
  State<RommCommentairePage> createState() => _RommCommentairePageState();
}

class _RommCommentairePageState extends State<RommCommentairePage> {
  late Future<RoomResponse?> futureApiResponse;
  String? storedUuid;

  Future<RoomResponse?> fetchApiResponse(String id_room) async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.get(
      Uri.parse(
          'https://spherechatbackdev.cmk.biz:4543/index.php/api/get-discussion-room/$id_room'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return RoomResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Retourner null pour indiquer que l'accès est refusé
    } else {
      throw Exception('Failed to load API response ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.roomId != "null") {
      futureApiResponse = fetchApiResponse(widget.roomId);
      _loadString();
    }
  }

  void _loadString() async {
    String? retrievedString = await SharedPrefernce.getToken('uuid');
    setState(() {
      storedUuid = retrievedString;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.roomId == "null"
        ? Container(
            child: const Center(
              child: Text("No Comment Room Available"),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Room Commanitaire'),
            ),
            body: FutureBuilder<RoomResponse?>(
              future: futureApiResponse,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Failed to load data: ${snapshot.error}'));
                } else if (snapshot.data == null) {
                  return const Center(
                      child: Text("You do not have access to this room"));
                } else if (snapshot.hasData) {
                  List<Message> messages = snapshot.data!.data;

                  // Trier les messages par date de création
                  messages.sort((a, b) => DateTime.parse(a.createdAt.toString())
                      .compareTo(DateTime.parse(b.createdAt.toString())));

                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      bool isCurrentUser = message.sender.uuid == storedUuid;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isCurrentUser)
                                CircleAvatar(
                                  backgroundImage: message.sender.image.length == 1
                                      ? null
                                      : NetworkImage(
                                          "https://spherebackdev.cmk.biz:4543/storage/uploads/${message.sender.image}"),
                                  backgroundColor: message.sender.image.length == 1
                                      ? Colors.blue
                                      : null,
                                  child: message.sender.image.length == 1
                                      ? Text(
                                          message.sender.image,
                                          style: const TextStyle(color: Colors.white),
                                        )
                                      : null,
                                  radius: 25,
                                ),
                              if (!isCurrentUser) const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isCurrentUser)
                                    Text(
                                      message.sender.name,
                                      style: TextStyle(
                                          color: Colors.grey[700], fontSize: 12),
                                    ),
                                  if (!isCurrentUser) const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isCurrentUser
                                          ? Colors.green
                                          : Colors.grey[400],
                                      borderRadius: BorderRadius.only(
                                        topRight: const Radius.circular(10),
                                        topLeft: const Radius.circular(10),
                                        bottomRight: isCurrentUser
                                            ? const Radius.circular(0)
                                            : const Radius.circular(10),
                                        bottomLeft: isCurrentUser
                                            ? const Radius.circular(10)
                                            : const Radius.circular(0),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.message,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          DateFormat('dd/MM/yyyy HH:mm').format(
                                              DateTime.parse(
                                                  message.createdAt.toString())),
                                          style: const TextStyle(
                                              color: Colors.white70, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isCurrentUser) const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text("No data available"));
                }
              },
            ),
          );
  }
}
