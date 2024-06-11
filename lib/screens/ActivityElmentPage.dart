// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import '../models/ActivityElment.dart/ActivityEementModel.dart';

import '../services/ApiActivityElement.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActivityElmentPage extends StatefulWidget {
  final String idElment;
  const ActivityElmentPage({Key? key, required this.idElment})
      : super(key: key);

  @override
  State<ActivityElmentPage> createState() => _ActivityElmentPageState();
}

class _ActivityElmentPageState extends State<ActivityElmentPage> {
  List<ActivityElment> _activityElements = [];
  List<ActivityElment> _activityElementUpcoming = [];
  List<ActivityElment> _activityElementHistory = [];
  late Map<int, bool>
      _expandedState; // Pour gérer l'état d'expansion des panels

  @override
  void initState() {
    super.initState();
    fetchActivityUpcoming("2", widget.idElment);
    fetchActivityHistory("0", widget.idElment);
    fetchActivityElements("1",
        widget.idElment); // Charger les données pour "Aujourd'hui" initialement
    _expandedState = {
      0: true,
      1: true,
      2: true,
    }; // Initialiser l'état d'expansion à true pour ouvrir tous les panneaux
  }

  void fetchActivityElements(String type, String idElement) async {
    try {
      List<ActivityElment>? response =
          await ApiActivityElement.fetchMeeting(idElement, type);

      if (response != null) {
        setState(() {
          _activityElements = response;
        });
      } else {
        print('Failed to fetch activity elements: response is null.');
      }
    } catch (e) {
      print('Error while fetching meeting: $e');
      print('Failed to fetch activity elements.');
    }
  }

  void fetchActivityUpcoming(String type, String idElement) async {
    try {
      List<ActivityElment>? response =
          await ApiActivityElement.fetchMeeting(idElement, type);

      if (response != null) {
        setState(() {
          _activityElementUpcoming = response;
        });
      } else {
        print('Failed to fetch activity elements: response is null.');
      }
    } catch (e) {
      print('Error while fetching meeting: $e');
      print('Failed to fetch activity elements.');
    }
  }

  void fetchActivityHistory(String type, String idElement) async {
    try {
      List<ActivityElment>? response =
          await ApiActivityElement.fetchMeeting(idElement, type);

      if (response != null) {
        setState(() {
          _activityElementHistory = response;
        });
      } else {
        print('Failed to fetch activity elements: response is null.');
      }
    } catch (e) {
      print('Error while fetching meeting: $e');
      print('Failed to fetch activity elements.');
    }
  }

  CircleAvatar getTaskIcon(int tasksTypeId) {
    Map<int, Icon> taskIcons = {
      1: Icon(
        Icons.meeting_room,
        color: Colors.white,
      ), // Icône pour le meeting
      2: Icon(Icons.email, color: Colors.white), // Icône pour le mail
      3: Icon(Icons.videocam, color: Colors.white), // Icône pour la visio
      4: Icon(Icons.call,
          color: Colors.white), // Icône pour l'intervention et service
      11: Icon(Icons.call, color: Colors.white), // Icône pour le call
      12: Icon(Icons.event, color: Colors.white), // Icône pour l'activité test
      16: Icon(Icons.event, color: Colors.white),
      // Icône pour l'activité test
    };

    Map<int, Color> taskColors = {
      1: Colors.blue, // Couleur pour le meeting
      2: Colors.red, // Couleur pour le mail
      3: Colors.green, // Couleur pour la visio
      4: Colors.orange, // Couleur pour l'intervention et service
      11: Colors.purple, // Couleur pour le call
      12: Colors.pink, // Couleur pour l'activité test
      16: Colors.teal, // Couleur pour l'activité test
    };

    Icon icon = taskIcons[tasksTypeId] ?? Icon(Icons.help);
    Color color = taskColors[tasksTypeId] ?? Colors.grey; // Couleur par défaut

    return CircleAvatar(
      backgroundColor: color,
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ExpansionPanelList(
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                _expandedState[panelIndex] = !isExpanded;
              });
            },
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      AppLocalizations.of(context).today,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
                body: _activityElements.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context).no_activities_today,
                        ),
                      )
                    : Column(
                        children: _activityElements.map((activityElement) {
                          return ListTile(
                            leading: getTaskIcon(activityElement.tasksTypeId),
                            title: Text(' ${activityElement.label}'),
                            subtitle: Text(
                                'Start Time: ${activityElement.startTime}'),
                            // Ajoutez ici le contenu supplémentaire du panneau
                          );
                        }).toList(),
                      ),
                isExpanded:
                    _expandedState.containsKey(0) ? _expandedState[0]! : false,
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      AppLocalizations.of(context).upcoming,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
                body: _activityElementUpcoming.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context).no_upcoming_activities,
                        ),
                      )
                    : Column(
                        children:
                            _activityElementUpcoming.map((activityElement) {
                          return ListTile(
                            leading: getTaskIcon(activityElement.tasksTypeId),
                            title: Text('Start Date: ${activityElement.label}'),
                            subtitle: Text(
                                'Start Time: ${activityElement.startTime}'),
                            // Ajoutez ici le contenu supplémentaire du panneau
                          );
                        }).toList(),
                      ),
                isExpanded:
                    _expandedState.containsKey(1) ? _expandedState[1]! : false,
              ),
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return ListTile(
                    title: Text(
                      AppLocalizations.of(context).history,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
                body: _activityElementHistory.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context).no_past_activities,
                        ),
                      )
                    : Column(
                        children:
                            _activityElementHistory.map((activityElement) {
                          return ListTile(
                            leading: getTaskIcon(activityElement.tasksTypeId),
                            title: Text(activityElement.label),
                            subtitle: Text(
                                'Start Date: ${activityElement.startDate}' +
                                    'Start Time: ${activityElement.startTime}'),
                            // Ajoutez ici le contenu supplémentaire du panneau
                          );
                        }).toList(),
                      ),
                isExpanded:
                    _expandedState.containsKey(2) ? _expandedState[2]! : false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
