// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'CustomFollowNotifcation.dart';
import 'CustomLikedNotifcation.dart';

class NotificationsPage extends StatelessWidget {
  NotificationsPage({Key? key}) : super(key: key);
  List newItem = ["liked", "follow"];
  List todayItem = ["follow", "liked", "liked"];

  List oldesItem = ["follow", "follow", "liked", "liked"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New",
                style: Theme.of(context).textTheme.headline2,
              ),
              const SizedBox(
                height: 10,
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: newItem.length,
                itemBuilder: (context, index) {
                  return newItem[index] == "follow"
                      ? CustomFollowNotifcation(
                          img1: "assets/img3.jpeg",
                          text: "Creer un ticket",
                          name: "samer arfaoui")
                      : CustomLikedNotifcation(
                          img1: "assets/face2.jpg",
                          img2: "assets/face3.jpg",
                          name1: "samer arfaoui",
                          name2: "wajdi el louzzi");
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Today",
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: todayItem.length,
                itemBuilder: (context, index) {
                  return todayItem[index] == "follow"
                      ? CustomFollowNotifcation(
                          img1: "assets/img3.jpeg",
                          text: "Creer un ticket",
                          name: "samer arfaoui")
                      : CustomLikedNotifcation(
                          img1: "assets/face2.jpg",
                          img2: "assets/face4.jpg",
                          name1: "samer arfaoui",
                          name2: "wajdi el louzzi");
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Oldest",
                  style: Theme.of(context).textTheme.headline2,
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: oldesItem.length,
                itemBuilder: (context, index) {
                  return oldesItem[index] == "follow"
                      ? CustomFollowNotifcation(
                          img1: "assets/img3.jpeg",
                          text: "Creer un ticket",
                          name: "samer arfaoui")
                      : CustomLikedNotifcation(
                          img1: "assets/face3.jpg",
                          img2: "assets/img1.jpeg",
                          name1: "samer arfaoui",
                          name2: "wajdi el louzzi");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
