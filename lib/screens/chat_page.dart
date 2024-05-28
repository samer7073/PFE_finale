// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Duration duration = new Duration();
  Duration position = new Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  @override
  Widget build(BuildContext context) {
    final now = new DateTime.now();
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                BubbleNormalImage(
                  id: 'id001',
                  image: Image.asset("assets/download.jpg"),
                  tail: true,
                  delivered: true,
                  seen: true,
                ),
                /* BubbleNormalAudio(
                  color: Color(0xFFE8E8EE),
                  duration: duration.inSeconds.toDouble(),
                  position: position.inSeconds.toDouble(),
                  isPlaying: isPlaying,
                  isLoading: isLoading,
                  isPause: isPause,
                  //onSeekChanged: _changeSeek,
                  //: _playAudio,
                  sent: true,
                ),
                */
                BubbleSpecialThree(
                  text: 'bubble normal with tail',
                  //isSender: false,
                  color: Colors.purple,
                  tail: true,
                  textStyle: TextStyle(color: Colors.white),
                ),
                BubbleSpecialThree(
                  text: 'bubble normal with tail',
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  isSender: true,
                  color: Colors.purple,
                  tail: true,
                  sent: true,
                ),
                DateChip(
                  color: Color.fromARGB(255, 246, 228, 250),
                  date: new DateTime(now.year, now.month, now.day - 2),
                ),
                BubbleSpecialThree(
                  text: 'bubble normal without tail',
                  isSender: false,
                  color: Color(0xFFE8E8EE),
                  tail: true,
                ),
                BubbleSpecialThree(
                  text: 'bubble normal without tail',
                  color: Colors.purple,
                  textStyle: TextStyle(color: Colors.white),
                  tail: true,
                  sent: true,
                  seen: true,
                  delivered: true,
                ),
                BubbleSpecialThree(
                  text: 'bubble special one with tail',
                  isSender: false,
                  color: Color(0xFFE8E8EE),
                  tail: true,
                ),
                DateChip(
                  color: Color.fromARGB(255, 246, 228, 250),
                  date: new DateTime(now.year, now.month, now.day - 1),
                ),
                BubbleSpecialThree(
                  text: 'bubble special one with tail',
                  color: Colors.purple,
                  textStyle: TextStyle(color: Colors.white),
                  seen: true,
                  tail: true,
                ),
                BubbleSpecialThree(
                  text: 'bubble special one without tail',
                  isSender: false,
                  tail: true,
                  color: Color(0xFFE8E8EE),
                ),
                BubbleSpecialThree(
                  text: 'bubble special one without tail',
                  tail: true,
                  color: Colors.purple,
                  textStyle: TextStyle(color: Colors.white),
                  sent: true,
                ),
                BubbleSpecialThree(
                  text: 'bubble special tow with tail',
                  isSender: false,
                  color: Color(0xFFE8E8EE),
                  tail: true,
                ),
                DateChip(
                  color: Color.fromARGB(255, 246, 228, 250),
                  date: now,
                ),
                BubbleSpecialThree(
                  text: 'bubble special tow with tail',
                  isSender: true,
                  color: Colors.purple,
                  textStyle: TextStyle(color: Colors.white),
                  sent: true,
                ),
                BubbleSpecialThree(
                  text: 'bubble special tow without tail',
                  isSender: false,
                  tail: true,
                  color: Color(0xFFE8E8EE),
                ),
                BubbleSpecialThree(
                  text: 'bubble special tow without tail',
                  tail: true,
                  color: Colors.purple,
                  textStyle: TextStyle(color: Colors.white),
                  delivered: true,
                ),
                BubbleSpecialThree(
                  text: 'bubble special three without tail',
                  tail: true,
                  color: Colors.purple,
                  textStyle: TextStyle(color: Colors.white),
                ),
                BubbleSpecialThree(
                  text: 'bubble special three with tail',
                  color: Colors.purple,
                  textStyle: TextStyle(color: Colors.white),
                  tail: true,
                ),
                BubbleSpecialThree(
                  text: "bubble special three without tail",
                  color: Color(0xFFE8E8EE),
                  tail: true,
                  isSender: false,
                ),
                BubbleSpecialThree(
                  text: "bubble special three with tail",
                  color: Color(0xFFE8E8EE),
                  tail: true,
                  isSender: false,
                ),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
          MessageBar(
            sendButtonColor: Colors.purple,
            onSend: (_) => print(_),
            actions: [
              InkWell(
                child: Icon(
                  Icons.add,
                  color: Colors.purple,
                  size: 24,
                ),
                onTap: () {},
              ),
              Padding(
                padding: EdgeInsets.only(left: 8, right: 8),
                child: InkWell(
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.purple,
                    size: 24,
                  ),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
