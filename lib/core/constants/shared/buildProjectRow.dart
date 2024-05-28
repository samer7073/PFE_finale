// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/userAvatar.dart';

import 'package:percent_indicator/percent_indicator.dart';

import '../../../screens/detail/TeamFolderPage.dart';


Widget buildCardVertical(
  String title,
  String petitetitle,
  List<String> filenames,
  Color color,
  double percentage,
  String textPercentage,
  String textDate,
  BuildContext context,
) {
  bool showAllImages = filenames.length <= 3;
  double availableScreenWidth = MediaQuery.of(context).size.width;
  double widthPercentage = 0.8; // Adjust this value based on your design

  return GestureDetector(
    /*  onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TeamFolderPage()),
      );
    },*/
    child: Card(
      //color: Colors.white,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 3,
            ),
            Container(
              width: availableScreenWidth * widthPercentage,
              height: 3,
              color: color,
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.headline2,
            ),
            const SizedBox(height: 8),
            Text(
              petitetitle,
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                CircularPercentIndicator(
                  radius: 15.0,
                  lineWidth: 4.0,
                  animation: true,
                  percent: percentage,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: color,
                ),
                const SizedBox(width: 5),
                Text(
                  textPercentage,
                ),
                Spacer(),
                Icon(
                  Icons.access_time,
                  color: color, // Updated color
                ),
                const SizedBox(width: 5),
                Text(
                  textDate,
                  /* style: TextStyle(
                    color: Colors.grey[600], // Updated color
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),*/
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                for (int i = 0; i < (showAllImages ? filenames.length : 3); i++)
                  UserAvatar(filename: filenames[i]),
                if (!showAllImages)
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                      //borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '+${filenames.length - 3}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeamFolderPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    backgroundColor: Color.fromARGB(255, 246, 228, 250),
                  ),
                  child: Text("Details",
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 145, 33, 250),
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
