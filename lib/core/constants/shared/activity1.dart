import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/buildCardHorizontal.dart';

class Activity1Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            children: [
              buildCardHorizontal(
                "Meet ",

                [
                  "img1.jpeg",
                  "img2.jpeg",
                  "img1.jpeg",
                  "img2.jpeg",
                ],
                Colors.deepPurple,
                // Updated color
                0.75,
                "75%",
                "28/02/2024",
                '09:00',
                context,
              ),
              SizedBox(
                height: 10,
              ),
              buildCardHorizontal(
                "camera ",
                [
                  "img1.jpeg",
                  "img2.jpeg",
                ],
                Colors.pink,
                // Updated color
                0.75,
                "75%",
                "28/02/2024",
                '08:00',
                context,
              ),
              SizedBox(
                height: 10,
              ),
              buildCardHorizontal(
                "email ",
                [
                  "img1.jpeg",
                  "img2.jpeg",
                ],
                Colors.blue,
                // Updated color
                0.75,
                "75%",
                "28/02/2024",
                '11:00',
                context,
              ),
              SizedBox(
                height: 10,
              ),
              buildCardHorizontal(
                "message",

                [
                  "img1.jpeg",
                  "img2.jpeg",
                ],
                Colors.deepPurple,
                // Updated color
                0.75,
                "75%",
                "28/02/2024",
                '12:00',
                context,
              ),
              SizedBox(
                height: 10,
              ),
              buildCardHorizontal(
                "taches",

                [
                  "img1.jpeg",
                  "img2.jpeg",
                  "img1.jpeg",
                  "img2.jpeg",
                ],
                Colors.pink,
                // Updated color
                0.75,
                "75%",
                "28/02/2024",
                '13:00',
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
