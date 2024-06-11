// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_application_stage_project/components/envent_card.dart';

class MyTimelineTile extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final bool isPast;
  final String title;
  final String time;
  final String name; // Ajout de l'attribut name

  const MyTimelineTile({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.isPast,
    required this.time,
    required this.title,
    required this.name, // Ajout du constructeur name
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10),
      child: TimelineTile(
        isFirst: isFirst,
        isLast: isLast,
        beforeLineStyle: LineStyle(
          color: Colors.green,
          thickness: 4,
        ),
        afterLineStyle: LineStyle(
          color: Colors.green,
          thickness: 4,
        ),
        indicatorStyle: IndicatorStyle(
          width: 40,
          height: 40,
          indicator: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPast ? Color.fromARGB(255, 23, 162, 28) : Colors.grey,
            ),
            child: Center(
              child: Icon(
                Icons.done,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
        endChild: EventCard(
          time: time,
          title: title,
          name: name, // Passage de name à EventCard
        ),
      ),
    );
  }
}
