// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/services/ApiDetailElment.dart';
import 'package:flutter_application_stage_project/services/ApiUpdateStageFamily.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/detailModel.dart';
import '../services/sharedPreference.dart';

class DetailPage extends StatefulWidget {
  final String elementId;
  final int pipeline_id;

  const DetailPage(
      {super.key, required this.elementId, required this.pipeline_id});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<DetailResponse> futureApiResponse;
  late Future<List<Stage>> futureStages;
  late Future<String> futurePipelineName;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    futureApiResponse = ApiDetailElment.getDetail(widget.elementId);
    futureStages = fetchStages(widget.pipeline_id);
    futurePipelineName = fetchPipelineName();
  }

  Future<List<Stage>> fetchStages(int pipelineId) async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.get(
      Uri.parse(
          'https://spherebackdev.cmk.biz:4543/index.php/api/mobile/stages/$pipelineId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<dynamic> stagesData = data['data'];
      return stagesData.map((stage) => Stage.fromJson(stage)).toList();
    } else {
      throw Exception('Failed to load stages');
    }
  }

  Future<String> fetchPipelineName() async {
    final token = await SharedPrefernce.getToken("token");
    final response = await http.get(
      Uri.parse(
          'https://spherebackdev.cmk.biz:4543/index.php/api/mobile/get-element-by-id/${widget.elementId}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return data['data']['Pipeline'];
    } else {
      throw Exception('Failed to load pipeline name');
    }
  }

  Future<void> updateStage(String elementId, int newStageId) async {
    final responseCode =
        await ApiUpdateStageFamily.fieldPost(elementId, newStageId.toString());
    if (responseCode == 200) {
      // Mise à jour réussie, recharge les données
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Stage updated successfully'),
        backgroundColor: Colors.green,
      ));
      setState(() {
        fetchData();
      });
    } else {
      // Échec de la mise à jour
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update stage'),
        backgroundColor: Colors.green,
      ));
    }
  }

  // Utility method to remove square brackets from strings
  String removeBrackets(String value) {
    return value.replaceAll('[', '').replaceAll(']', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DetailResponse>(
        future: futureApiResponse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No details found'));
          } else {
            var detailData = snapshot.data!;
            int selectedStageId = detailData.data['stage_id'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                /*
                FutureBuilder<String>(
                  future: futurePipelineName,
                  builder: (context, pipelineSnapshot) {
                    if (pipelineSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (pipelineSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${pipelineSnapshot.error}'));
                    } else if (!pipelineSnapshot.hasData) {
                      return Center(child: Text('No pipeline name found'));
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pipelineSnapshot.data!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            FutureBuilder<List<Stage>>(
                              future: futureStages,
                              builder: (context, stagesSnapshot) {
                                if (stagesSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (stagesSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Error: ${stagesSnapshot.error}'));
                                } else if (!stagesSnapshot.hasData ||
                                    stagesSnapshot.data!.isEmpty) {
                                  return Center(child: Text('No stages found'));
                                } else {
                                  List<Stage> stages = stagesSnapshot.data!;
                                  return DropdownButton<int>(
                                    value: selectedStageId,
                                    items: stages.map((Stage stage) {
                                      return DropdownMenuItem<int>(
                                        value: stage.id,
                                        child: Text(stage.label),
                                      );
                                    }).toList(),
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          selectedStageId = newValue;
                                          updateStage(
                                              widget.elementId, newValue);
                                        });
                                      }
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                */
                FutureBuilder<List<Stage>>(
                  future: futureStages,
                  builder: (context, stagesSnapshot) {
                    if (stagesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (stagesSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${stagesSnapshot.error}'));
                    } else if (!stagesSnapshot.hasData ||
                        stagesSnapshot.data!.isEmpty) {
                      return Center(child: Text('No stages found'));
                    } else {
                      List<Stage> stages = stagesSnapshot.data!;
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: stages.map((stage) {
                            bool isSelected = stage.id == selectedStageId;
                            return GestureDetector(
                              onTap: () {
                                updateStage(widget.elementId, stage.id);
                              },
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 15.0),
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Text(
                                      stage.label,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      height: 2.0,
                                      color: Color(int.parse(stage.color
                                          .replaceFirst('#', '0xff'))),
                                      width: 60.0,
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }
                  },
                ),
                Expanded(
                  child: ListView(
                    children: detailData.data.entries
                        .where((entry) => entry.key != 'id')
                        .map((entry) {
                      return ListTile(
                        title: Text(
                          entry.key.toUpperCase(),
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        subtitle: Text(
                          removeBrackets(entry.value.toString()),
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class Stage {
  final int id;
  final String label;
  final String color;

  Stage({required this.id, required this.label, required this.color});

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      id: json['id'],
      label: json['label'],
      color: json['color'],
    );
  }
}
