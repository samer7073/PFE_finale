// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomFollowNotifcation extends StatelessWidget {
  final String img1;
  final String text;
  final String name;

  const CustomFollowNotifcation({
    Key? key,
    required this.img1,
    required this.text,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 70,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage(img1),
              ),
              Positioned(
                  left: 40,
                  bottom: 0,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.blue),
                    child: Icon(
                      Icons.airplane_ticket_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                  ))
            ],
          ),
        ),
        SizedBox(
          width: 0,
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              text,
            ),
          ],
        ),
        SizedBox(
          height: 70,
        )
      ],
    );
  }
}
