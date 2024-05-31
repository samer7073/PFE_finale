// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';

class ticketListRow extends StatelessWidget {
  final IconData SourceIcon;
  final String id;
  final String title;
  final String owner;
  final String createTime;
  final IconData stateIcon;
  final String stateMessage;
  final Color colorContainer;
  final String messageContainer;
  final String ownerImage;
  final String Pipeline;

  const ticketListRow(
      {super.key,
      required this.SourceIcon,
      required this.id,
      required this.title,
      required this.owner,
      required this.createTime,
      required this.stateIcon,
      required this.stateMessage,
      required this.colorContainer,
      required this.messageContainer,
      required this.ownerImage,
      required this.Pipeline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Ref :",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    id,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  )
                ],
              ),
              Text(
                createTime,
                style: Theme.of(context).textTheme.bodyText2,
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Label : ",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
              SizedBox(
                width: 10,
              ),
              Container(
                child: Center(
                  child: Text(
                    messageContainer,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                height: 30,
                width: 100,
                decoration: BoxDecoration(
                    color: colorContainer,
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(20), right: Radius.circular(20))),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Pipeline : ",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(Pipeline,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
              Row(
                children: [
                  Text(
                    owner,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ownerImage.length == 1
                      ? CircleAvatar(
                          backgroundColor: Colors
                              .blue, // Choisissez une couleur de fond appropriée
                          child: Text(
                            ownerImage,
                            style: TextStyle(
                                color: Colors
                                    .white), // Choisissez une couleur de texte appropriée
                          ),
                          radius: 15,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(
                              "https://spherebackdev.cmk.biz:4543/storage/uploads/$ownerImage"),
                          radius: 15,
                        ),
                ],
              ),
            ],
          ),
          Divider()
        ],
      ),
    );
  }
}
