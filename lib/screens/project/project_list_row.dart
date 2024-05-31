// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:math';

import 'package:flutter/material.dart';

class ProjectListRow extends StatelessWidget {
  final String reference;
  final String title;
  final String owner;
  final String ownerImage;
  final String createTime;
  final String pipline;
  const ProjectListRow(
      {super.key,
      required this.reference,
      required this.title,
      required this.owner,
      required this.ownerImage,
      required this.createTime,
      required this.pipline});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Ref : ",
                  style: TextStyle(color: Colors.black),
                ),
                Text(
                  reference,
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
                Text(
                  pipline,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    );
  }
}
