import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';
import 'package:flutter_application_stage_project/services/ApiDetailElment.dart';
import 'package:flutter_application_stage_project/services/ApiUpdateStageFamily.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../models/detailModel.dart';
import '../providers/theme_provider.dart';
import '../services/sharedPreference.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetailPage extends StatefulWidget {
  final String elementId;
  final int? pipeline_id; // pipeline_id peut être null

  const DetailPage(
      {super.key, required this.elementId, required this.pipeline_id});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<DetailResponse> futureApiResponse;
  late Future<List<Stage>> futureStages;
  late Future<String> futurePipelineName;
  late ThemeProvider themeProvider;
  bool isLoading = true; // État de chargement global

  @override
  void initState() {
    super.initState();
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    fetchData();
  }

  late int? pipelineID; // pipelineID peut être null

  void fetchData() async {
    try {
      futureApiResponse = ApiDetailElment.getDetail(widget.elementId);
      final response = await futureApiResponse;
      setState(() {
        pipelineID = response.data['pipeline_id'];
      });

      if (pipelineID != null) {
        futureStages = fetchStages(pipelineID!);
        futurePipelineName = fetchPipelineName();

        // Attendre que tous les futurs soient terminés
        await Future.wait([futureStages, futurePipelineName]);
      }
    } catch (e) {
      // Gérer les erreurs éventuelles
      print('Erreur lors du chargement des données: $e');
    } finally {
      setState(() {
        isLoading = false; // Chargement terminé
      });
    }
  }

  Future<List<Stage>> fetchStages(int pipelineId) async {
    final token = await SharedPrefernce.getToken("token");
    final baseUrl = await Config.getApiUrl("StageKanban");
    log(baseUrl + "*************************");

    final response = await http.get(
      Uri.parse('$baseUrl$pipelineId'),
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
      throw Exception('Impossible de charger les stages');
    }
  }

  Future<String> fetchPipelineName() async {
    final token = await SharedPrefernce.getToken("token");
    final baseUrl = await Config.getApiUrl("pipeline");
    log("5555555555555" + baseUrl + widget.elementId);

    final response = await http.get(
      Uri.parse(baseUrl + widget.elementId),
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
      throw Exception('Impossible de charger le nom du pipeline');
    }
  }

  Future<void> updateStage(String elementId, int newStageId) async {
    final responseCode =
        await ApiUpdateStageFamily.fieldPost(elementId, newStageId.toString());
    if (responseCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Stage mis à jour avec succès',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ));
      setState(() {
        fetchData();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Échec de la mise à jour du stage',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  String removeBrackets(String value) {
    return value.replaceAll('[', '').replaceAll(']', '');
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      // Affichage du chargement global
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
      );
    }

    return Scaffold(
      body: FutureBuilder<DetailResponse>(
        future: futureApiResponse,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Aucun détail trouvé'));
          } else {
            var detailData = snapshot.data!;
            int? selectedStageId = detailData.data['stage_id'];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (pipelineID == null || selectedStageId == null) ...[
                      // Votre code existant pour le message d'avertissement
                    ] else ...[
                      FutureBuilder<String>(
                        future: futurePipelineName,
                        builder: (context, pipelineSnapshot) {
                          if (pipelineSnapshot.hasError) {
                            return Center(
                                child:
                                    Text('Erreur: ${pipelineSnapshot.error}'));
                          } else if (!pipelineSnapshot.hasData) {
                            return Center(
                                child: Text('Aucun nom de pipeline trouvé'));
                          } else {
                            String pipelineName = pipelineSnapshot.data!;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.pipeline +
                                        " ",
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '$pipelineName',
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      FutureBuilder<List<Stage>>(
                        future: futureStages,
                        builder: (context, stagesSnapshot) {
                          if (stagesSnapshot.hasError) {
                            return Center(
                                child: Text('Erreur: ${stagesSnapshot.error}'));
                          } else if (!stagesSnapshot.hasData ||
                              stagesSnapshot.data!.isEmpty) {
                            return Center(child: Text('Aucun stage trouvé'));
                          } else {
                            List<Stage> stages = stagesSnapshot.data!;
                            return Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: themeProvider.isDarkMode
                                    ? Colors.black
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: stages.map((stage) {
                                    bool isSelected =
                                        stage.id == selectedStageId;
                                    return GestureDetector(
                                      onTap: () {
                                        updateStage(widget.elementId, stage.id);
                                      },
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 15.0),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.blue
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.white,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Text(
                                          stage.label,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                    Text(
                      AppLocalizations.of(context)!.details,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: themeProvider.isDarkMode
                            ? Colors.black
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.isDarkMode
                                ? Colors.black
                                : Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: detailData.data.entries
                            .where((entry) =>
                                entry.key != 'id' && entry.key != 'stage_id'&& entry.key!='pipeline_id')
                            .map((entry) {
                          return ListTile(
                            title: Text(
                              entry.key.toUpperCase(),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            subtitle: Text(
                              removeBrackets(entry.value.toString()),
                              style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                  ],
                ),
              ),
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
