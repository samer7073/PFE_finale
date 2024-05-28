// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/KanbanModels/Element.dart';
import 'package:flutter_application_stage_project/models/KanbanModels/KanbanResponse.dart';
import 'package:flutter_application_stage_project/screens/loading.dart';
import 'package:flutter_application_stage_project/services/GetKanbanApi.dart';

import '../models/pipelines/pipelineModel.dart';
import '../models/pipelines/pipelineRespone.dart';
import '../services/ApiDeleteElment.dart';
import '../services/ApiGetPiplineAllFamilies.dart';
import 'Card.dart';
import 'detailElment.dart';

class PipelineScreen extends StatefulWidget {
  final String idFamily;

  PipelineScreen({required this.idFamily});

  @override
  _PipelineScreenState createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  Pipeline? selectedPipeline;
  int? selectedStageId;
  List<KanbanElement>? kanbanData;
  void deleteKanbanElement(KanbanElement element) async {
    setState(() {
      kanbanData!.remove(element);
    });
    try {
      final delteResponse =
          await ApiDeleteElment.DeleteElment({"ids[]": element.elementId});
      if (delteResponse == 200) {
        // Show success snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            action: SnackBarAction(label: "Ok", onPressed: () {}),
            content: Text('Element supprimer avec succès !'),
          ),
        );
      } else {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : Element non supprimé")),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : Element non supprimé")),
      );
    }
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: FutureBuilder<PipelineResponse>(
              future: GetPipelineApi.getPipelines(widget.idFamily),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
                    return Center(
                      child: Text('No pipelines found'),
                    );
                  }
                  selectedPipeline ??= snapshot.data!.data.first;
                  log("------------------" + selectedPipeline!.id.toString());

                  return Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: DropdownButton<Pipeline>(
                              isExpanded: false,
                              value: selectedPipeline,
                              onChanged: (Pipeline? newValue) {
                                setState(() {
                                  selectedPipeline = newValue;
                                  selectedStageId = null;
                                  kanbanData =
                                      null; // Réinitialiser kanbanData à null lors du changement de pipeline
                                });
                              },
                              items: snapshot.data!.data
                                  .map<DropdownMenuItem<Pipeline>>(
                                      (Pipeline pipeline) {
                                return DropdownMenuItem<Pipeline>(
                                  value: pipeline,
                                  child: Text(
                                    pipeline.label,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0,
                                        color: Colors.black),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: selectedPipeline!.stages.map((stage) {
                            bool isSelected = stage.id == selectedStageId;
                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  selectedStageId = stage.id;
                                  loading = true;
                                });
                                try {
                                  KanbanResponse kanbanResponse =
                                      await GetKanbanApi.getKanban(
                                          stage.id.toString());
                                  setState(() {
                                    kanbanData = kanbanResponse.data;
                                    loading = false;
                                  });
                                } catch (e) {
                                  print('Error fetching kanban data: $e');
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 15.0,
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  color: selectedStageId == stage.id
                                      ? Color.fromARGB(255, 82, 104, 250)
                                      : Color.fromARGB(255, 242, 242, 242),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Text(
                                  stage.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (kanbanData == null || kanbanData!.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              'Aucune donnée à afficher pour cette étape',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      else if (selectedStageId == null)
                        Text(
                          'Please select a stage to view data',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: kanbanData!.length,
                            itemBuilder: (BuildContext context, int index) {
                              KanbanElement stageKanban = kanbanData![index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return DetailElment(
                                        idElment: stageKanban.elementId,
                                        idFamily: widget.idFamily,
                                        roomId: "1000",
                                        refenrce: stageKanban.reference,
                                        label: stageKanban.labelData,
                                        pipeline_id: selectedPipeline!.id,
                                      );
                                    },
                                  ));
                                },
                                child: Cardwidget(
                                  element: stageKanban,
                                  deleteFunction: deleteKanbanElement,
                                  familyId: widget.idFamily,
                                ),
                              );
                            },
                          ),
                        )
                    ],
                  );
                }
              },
            ),
          );
  }
}
