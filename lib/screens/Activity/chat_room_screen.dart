import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';

class ChatRoomScreen extends StatefulWidget {
  final Task task;

  ChatRoomScreen({required this.task});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [];

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    setState(() {
      messages.add({
        'message': _messageController.text,
        'sender': 'me',
        'avatar':
            'my_avatar.png', // Remplacez par l'URL de l'avatar de l'utilisateur
      });
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(messages[index]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    bool isMe = message['sender'] == 'me';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (!isMe)
            CircleAvatar(
              backgroundImage: AssetImage('assets/${message['avatar']}'),
              radius: 18,
            ),
          if (!isMe) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 14.0),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.purple[100] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Text(
                    message['message'],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 10),
          if (isMe)
            CircleAvatar(
              backgroundImage: AssetImage('assets/${message['avatar']}'),
              radius: 18,
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.purple,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
