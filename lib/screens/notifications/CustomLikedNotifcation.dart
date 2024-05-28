// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class CustomLikedNotifcation extends StatelessWidget {
  final String img1;
  final String img2;
  final String name1;
  final String name2;
  const CustomLikedNotifcation(
      {super.key,
      required this.img1,
      required this.img2,
      required this.name1,
      required this.name2});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 80,
          width: 68,
          child: Stack(children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(img1),
              ),
            ),
            Positioned(
              bottom: 10,
              child: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(img2),
              ),
            ),
            Positioned(
                left: 40,
                bottom: 5,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.green),
                  child: Icon(
                    Icons.chat_bubble,
                    size: 15,
                    color: Colors.white,
                  ),
                ))
          ]),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                maxLines: 2,
                text: TextSpan(
                    text: name1,
                    style: Theme.of(context).textTheme.bodyText1,
                    children: [
                      TextSpan(
                          text: " and \n",
                          style: Theme.of(context).textTheme.bodyText2),
                      TextSpan(text: name2)
                    ]),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Liked your recipe  .  h1",
              )
            ],
          ),
        ),
      ],
    );
  }
}
