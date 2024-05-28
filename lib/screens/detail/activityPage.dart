import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/activity1.dart';
import 'package:flutter_application_stage_project/providers/langue_provider.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';

import 'package:provider/provider.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  late ThemeProvider themeProvider;
  late LangueProvider langueProvider;

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    langueProvider = Provider.of<LangueProvider>(context, listen: false);
  }

  bool showTodayActivities = false;

  List<Widget> allActivities = [Activity1Content()];
  List<Widget> todayActivities = []; // Ajoutez vos activités d'aujourd'hui ici

  List<Widget> getDisplayedActivities() {
    if (showTodayActivities) {
      return todayActivities;
    } else {
      return allActivities;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Text(
              showTodayActivities
                  ? 'Toutes les activités'
                  : 'Activités d\'aujourd\'hui',
              style: TextStyle(fontSize: 16),
            ),
            trailing: Switch(
              value: showTodayActivities,
              onChanged: (value) {
                setState(() {
                  showTodayActivities = value;
                });
              },
            ),
          ),
          Expanded(
            child: PageView(
              children: getDisplayedActivities(),
            ),
          ),
        ],
      ),
    );
  }
}
