// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/chat_page.dart';

import 'CustomSearchDelegate.dart';

class DisscussionsPage extends StatefulWidget {
  const DisscussionsPage({super.key});

  @override
  State<DisscussionsPage> createState() => _DisscussionsPageState();
}

class _DisscussionsPageState extends State<DisscussionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Discussion"),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: CustomSearchDelegate("6"));
              },
              icon: Icon(
                Icons.search,
                size: 30,
              )),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              discussionRow("Ticket : ", "Unable to update app",
                  "Lorem ipsum dolor sit amet . 23:58", 'assets/face4.jpg'),
              SizedBox(
                height: 20,
              ),
              discussionRow("Deal : ", "Unable to update app",
                  "Lorem ipsum dolor sit amet . 23:58", 'assets/face2.jpg'),
              SizedBox(
                height: 20,
              ),
              discussionRow("Activity : ", "Unable to update app",
                  "Lorem ipsum dolor sit amet . 23:58", 'assets/download.jpg'),
              SizedBox(
                height: 20,
              ),
              discussionRow("Activity : ", "Unable to update app",
                  "Lorem ipsum dolor sit amet . 23:58", 'assets/face3.jpg'),
              SizedBox(
                height: 20,
              ),
              discussionRow("Ticket : ", "Unable to update app",
                  "Lorem ipsum dolor sit amet . 23:58", 'assets/img3.jpeg'),
              SizedBox(
                height: 20,
              ),
              discussionRow("Deal : ", "Unable to update app",
                  "Lorem ipsum dolor sit amet . 23:58", 'assets/img2.jpeg'),
              SizedBox(
                height: 20,
              ),
              discussionRow("Deal : ", "Unable to update app",
                  "Lorem ipsum dolor sit amet . 23:58", 'assets/img1.jpeg'),
              SizedBox(
                height: 20,
              ),
              discussionRow("Ticket : ", "Unable to update app",
                  "Lorem ipsum dolor sit amet . 23:58", 'assets/face5jpg.jpg'),
              SizedBox(
                height: 20,
              ),
              discussionRow("Deal : ", "Unable to update app",
                  "Lorem ipsum dolor sit amet . 23:58", 'assets/face4.jpg'),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector discussionRow(
      String type, String title, String lastMessage, String imageAsset) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return ChatPage();
          },
        ));
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: Image.asset(imageAsset).image,
            radius: 30,
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    type,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(lastMessage, style: Theme.of(context).textTheme.caption),
            ],
          )
        ],
      ),
    );
  }
}
