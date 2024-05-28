import 'package:flutter/material.dart';

import '../buildProjectRow.dart';


class Stage5Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: [
              const SizedBox(
                height: 20,
              ),
              buildCardVertical(
                "Shop integration with Facebook Api",
                "Use this guide to learn about concepts and common use cases for planning your commerce integration. For platform-partner-specific integrations, see Commerce Integration for Platform Partners.",
                [
                  "img1.jpeg",
                ],
                Colors.blue,
                // Updated color
                0.3,
                "30%",
                "28/02/2024",
                context,
              ),
              buildCardVertical(
                "Dessin Meeting ",
                "Use this guide to learn about concepts and common use cases for planning your commerce integration. For platform-partner-specific integrations, see Commerce Integration for Platform Partners.",
                [
                  "img1.jpeg",
                  "img2.jpeg",
                  "img3.jpeg",
                  "img2.jpeg",
                ],
                Colors.pink, // Updated color

                0.5,
                "50%",
                "28/02/2024",
                context,
              ),
              buildCardVertical(
                "Shop integration with Facebook Api",
                "Use this guide to learn about concepts and common use cases for planning your commerce integration. For platform-partner-specific integrations, see Commerce Integration for Platform Partners.",
                [
                  "img1.jpeg",
                ],
                Colors.blue, // Updated color
                // Updated color
                0.3,
                "30%",
                "28/02/2024",
                context,
              ),
              buildCardVertical(
                "Dessin Meeting ",
                "Use this guide to learn about concepts and common use cases for planning your commerce integration. For platform-partner-specific integrations, see Commerce Integration for Platform Partners.",
                [
                  "img1.jpeg",
                  "img2.jpeg",
                  "img3.jpeg",
                  "img2.jpeg",
                ],
                Colors.pink,
                // Updated color
                0.5,
                "50%",
                "28/02/2024",
                context,
              ),
              buildCardVertical(
                "Job interview ",
                "Use this guide to learn about concepts and common use cases for planning your commerce integration. For platform-partner-specific integrations, see Commerce Integration for Platform Partners.",
                [
                  "img1.jpeg",
                  "img2.jpeg",
                ],
                Colors.deepPurple,
                // Updated color
                0.75,
                "75%",
                "28/02/2024",
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
