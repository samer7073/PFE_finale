import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/chatUserModel/chatUserModel.dart';
import 'package:flutter_application_stage_project/models/commanitaireRoom/Message.dart';
import 'package:flutter_application_stage_project/services/chat/chat.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../core/constants/shared/config.dart';
import '../models/commanitaireRoom/ResponeRoom.dart';
import '../services/sharedPreference.dart';

class RommCommanitairePage extends StatefulWidget {
  final String roomId;
  const RommCommanitairePage({Key? key, required this.roomId})
      : super(key: key);

  @override
  State<RommCommanitairePage> createState() => _RommCommanitairePageState();
}

class _RommCommanitairePageState extends State<RommCommanitairePage> {
 late List<ChatUser> Users= [];
  late Future<ApiResponseRoom?> futureApiResponse;
  String? storedUuid;
  late Future<String> imageUrlFuture;

  Future<ApiResponseRoom?> fetchApiResponse(String id_room) async {
    log("999999999999  dans fetch romm ");
    final token = await SharedPrefernce.getToken("token");
    final baseUrl = await Config.getApiUrl('chatRomm');
    final url='$baseUrl$id_room?type=task';
   
   
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    log("999999999999 chat room status code ${response.statusCode}");

    if (response.statusCode == 200) {
      
      return ApiResponseRoom.fromJson(json.decode(response.body));
      
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
      imageUrlFuture = Config.getApiUrl("urlImage");
      _loadString();
      fetchUsers();
    }
  }
  Future<void> fetchUsers() async {
    
    try {
      final userResponse = await ChatRomm.fetchAllUsers();
      setState(() {
        Users=userResponse;
        log("users ${Users.length}");
       
       
      });
    } catch (e) {
      log('Failed to fetch Users: $e');
      
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
            body: FutureBuilder<ApiResponseRoom?>(
              future: futureApiResponse,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
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

                  return FutureBuilder<String>(
                    future: imageUrlFuture,
                    builder: (context, imageUrlSnapshot) {
                      if (imageUrlSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
                      } else if (imageUrlSnapshot.hasError) {
                        return Center(
                            child: Text(
                                'Failed to load image URL: ${imageUrlSnapshot.error}'));
                      } else if (imageUrlSnapshot.hasData) {
                        String baseUrl = imageUrlSnapshot.data ?? "";

                        return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            ChatUser user=
                            Users.firstWhere(
    (user) => user.uuid == message.senderUuid,
    orElse: () => ChatUser(id: "id", name: "name", email: "email", status:0),
  );
                            bool isCurrentUser =
                                message.senderUuid == storedUuid;
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
                                        backgroundImage: user
                                                    .image!.length ==
                                                1
                                            ? null
                                            : NetworkImage(
                                                "$baseUrl${user.image}"),
                                        backgroundColor:
                                            user.image!.length == 1
                                                ? Colors.blue
                                                : null,
                                        child: user.image!.length == 1
                                            ? Text(
                                                user.image!,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              )
                                            : null,
                                        radius: 25,
                                      ),
                                      
                                    if (!isCurrentUser)
                                      const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (!isCurrentUser)
                                        
                                          Text(
                                            user.name,
                                            style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 12),
                                          ),
                                          
                                        if (!isCurrentUser)
                                          const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: isCurrentUser
                                                ?  const Color.fromARGB(255, 83, 196, 222)
                                                : Colors.grey[400],
                                            borderRadius: BorderRadius.only(
                                              topRight:
                                                  const Radius.circular(10),
                                              topLeft:
                                                  const Radius.circular(10),
                                              bottomRight: isCurrentUser
                                                  ? const Radius.circular(0)
                                                  : const Radius.circular(10),
                                              bottomLeft: isCurrentUser
                                                  ? const Radius.circular(10)
                                                  : const Radius.circular(0),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              
                                              Text(
                                                message.message,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                DateFormat('dd/MM/yyyy HH:mm')
                                                    .format(DateTime.parse(
                                                        message.createdAt
                                                            .toString())),
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (isCurrentUser)
                                      const SizedBox(width: 10),
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
                  );
                } else {
                  return const Center(child: Text("No data available"));
                }
              },
            ),
          );
  }
}
