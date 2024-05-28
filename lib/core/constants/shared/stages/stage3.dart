import 'package:flutter/material.dart';

import '../buildProjectRow.dart';




class Stage3Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const SizedBox(height: 20),
          buildCardVertical(
            "Project 1",
            "Description of Project 1",
            ["img1.jpeg"],
            Colors.blue,
            0.3,
            "30%",
            "28/02/2024",
            context,
          ),
          // ... add more project rows
        ],
      ),
    );
  }
}
