import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/userAvatar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:timeline_tile/timeline_tile.dart';

Widget buildCardHorizontal(
  String title,
  List<String> filenames,
  Color color,
  double percentage,
  String textPercentage,
  String textDate,
  String textTime,
  BuildContext context,
) {
  bool showAllImages = filenames.length <= 3;
  double availableScreenWidth = MediaQuery.of(context).size.width;
  double widthPercentage = 0.8; // Adjust this value based on your design

  return GestureDetector(
    onTap: () {
      /*Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TeamFolderPage()),
      );*/
    },
    child: Row(
      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTimeline(color, textTime),
        SizedBox(width: 15), // Adjust as needed
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: SizedBox(
                width: availableScreenWidth * widthPercentage,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 3,
                      color: color,
                    ),
                    SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headline6,
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
                          color: color,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          textDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        for (int i = 0;
                            i < (showAllImages ? filenames.length : 3);
                            i++)
                          Flexible(
                            child: UserAvatar(filename: filenames[i]),
                          ),
                        if (!showAllImages)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '+${filenames.length - 3}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildTimeline(Color color, String textTime) {
  return SizedBox(
    width: 60,
    child: TimelineTile(
      axis: TimelineAxis.vertical,
      alignment: TimelineAlign.center,
      indicatorStyle: IndicatorStyle(
        width: 20,
        color: color,
        padding: EdgeInsets.all(6),
      ),
      startChild: SizedBox.shrink(),
      endChild: SizedBox(
        height: 60,
        width: 20,
        child: Text(
          textTime, // Placeholder, replace with actual time
          style: TextStyle(fontSize: 12, color: color),
        ),
      ),
    ),
  );
}
