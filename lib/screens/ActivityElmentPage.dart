// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/ActivityElment.dart/ActivityEementModel.dart';
import '../services/ApiActivityElement.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';

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
  late Map<int, bool> _expandedState;
  late Future<String> imageUrlFuture;

  @override
  void initState() {
    super.initState();
    imageUrlFuture = Config.getApiUrl("urlImage");
    fetchActivityUpcoming("2", widget.idElment);
    fetchActivityHistory("0", widget.idElment);
    fetchActivityElements("1", widget.idElment);
    _expandedState = {
      0: true,
      1: true,
      2: true,
    };
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
    Map<int, FaIcon> taskIcons = {
      1: FaIcon(FontAwesomeIcons.meetup, color: Colors.white),
      2: FaIcon(FontAwesomeIcons.envelope, color: Colors.white),
      3: FaIcon(FontAwesomeIcons.video, color: Colors.white),
      4: FaIcon(FontAwesomeIcons.phone, color: Colors.white),
      11: FaIcon(FontAwesomeIcons.phone, color: Colors.white),
      12: FaIcon(FontAwesomeIcons.calendar, color: Colors.white),
      16: FaIcon(FontAwesomeIcons.calendarCheck, color: Colors.white),
    };

    Map<int, Color> taskColors = {
      1: Colors.blue,
      2: Colors.red,
      3: Colors.green,
      4: Colors.orange,
      11: Colors.purple,
      12: Colors.pink,
      16: Colors.teal,
    };

    FaIcon icon = taskIcons[tasksTypeId] ?? FaIcon(FontAwesomeIcons.question);
    Color color = taskColors[tasksTypeId] ?? Colors.grey;

    return CircleAvatar(
      backgroundColor: color,
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String>(
        future: imageUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading image URL'));
          }

          String baseUrl = snapshot.data ?? "";

          return ListView(
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
                                leading:
                                    getTaskIcon(activityElement.tasksTypeId),
                                title: Text(activityElement.label),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Start Date: ${activityElement.startDate}'),
                                        Text(
                                            'End Date: ${activityElement.endDate}')
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                            'Start Time: ${activityElement.startTime}'),
                                        SizedBox(
                                          width: 64,
                                        ),
                                        Text(
                                            'End Time: ${activityElement.endTime}'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(activityElement.owner.label),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        activityElement.owner.avatar.length == 1
                                            ? CircleAvatar(
                                                backgroundColor: Colors
                                                    .blue, // Choisissez une couleur de fond appropriée
                                                child: Text(
                                                  activityElement.owner.avatar,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white), // Choisissez une couleur de texte appropriée
                                                ),
                                                radius: 15,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    "$baseUrl${activityElement.owner.avatar}"),
                                                radius: 15,
                                              ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    isExpanded: _expandedState.containsKey(0)
                        ? _expandedState[0]!
                        : false,
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
                              AppLocalizations.of(context)
                                  .no_upcoming_activities,
                            ),
                          )
                        : Column(
                            children:
                                _activityElementUpcoming.map((activityElement) {
                              return ListTile(
                                leading:
                                    getTaskIcon(activityElement.tasksTypeId),
                                title: Text(activityElement.label),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Start Date: ${activityElement.startDate}'),
                                        Text(
                                            'End Date: ${activityElement.endDate}')
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Start Time: ${activityElement.startTime}'),
                                        Text(
                                            'End Time: ${activityElement.endTime}'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(activityElement.owner.label),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        activityElement.owner.avatar.length == 1
                                            ? CircleAvatar(
                                                backgroundColor: Colors
                                                    .blue, // Choisissez une couleur de fond appropriée
                                                child: Text(
                                                  activityElement.owner.avatar,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white), // Choisissez une couleur de texte appropriée
                                                ),
                                                radius: 15,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    "$baseUrl${activityElement.owner.avatar}"),
                                                radius: 15,
                                              ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    isExpanded: _expandedState.containsKey(1)
                        ? _expandedState[1]!
                        : false,
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
                                leading:
                                    getTaskIcon(activityElement.tasksTypeId),
                                title: Text(activityElement.label),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Start Date: ${activityElement.startDate}'),
                                        Text(
                                            'End Date: ${activityElement.endDate}')
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Start Time: ${activityElement.startTime}'),
                                        Text(
                                            'End Time: ${activityElement.endTime}'),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(activityElement.owner.label),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        activityElement.owner.avatar.length == 1
                                            ? CircleAvatar(
                                                backgroundColor: Colors
                                                    .blue, // Choisissez une couleur de fond appropriée
                                                child: Text(
                                                  activityElement.owner.avatar,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .white), // Choisissez une couleur de texte appropriée
                                                ),
                                                radius: 15,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    "$baseUrl${activityElement.owner.avatar}"),
                                                radius: 15,
                                              ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    isExpanded: _expandedState.containsKey(2)
                        ? _expandedState[2]!
                        : false,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
