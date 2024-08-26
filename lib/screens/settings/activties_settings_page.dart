// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/components/my_time_line_tiel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ActiviteSettingsPage extends StatefulWidget {
  const ActiviteSettingsPage({super.key});

  @override
  State<ActiviteSettingsPage> createState() => _ActiviteSettingsPageState();
}

class _ActiviteSettingsPageState extends State<ActiviteSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.activities),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: ListView(
          children: [
            MyTimelineTile(
              name: "samer",
              isFirst: true,
              isLast: false,
              isPast: true,
              time: "13:00 PM",
              title: "Believing is the absence of doubt",
            ),
            MyTimelineTile(
              name: "samer",
              isFirst: false,
              isLast: false,
              isPast: true,
              time: "12:00 PM ",
              title: "Start With A baseline",
            ),
            MyTimelineTile(
              name: "samer",
              isFirst: false,
              isLast: false,
              isPast: true,
              time: "11:00 PM  ",
              title: "Break through self doubt and fear",
            ),
            MyTimelineTile(
              name: "samer",
              isFirst: false,
              isLast: false,
              isPast: true,
              time: "10:00  PM",
              title: "Believing is the absence of doubt",
            ),
          ],
        ),
      ),
    );
  }
}
