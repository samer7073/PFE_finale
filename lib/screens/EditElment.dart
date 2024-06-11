// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/FieldWidgetGeneratorUpdate.dart';
import 'package:flutter_application_stage_project/models/fields/update/dataFieldGroupUpdate.dart';
import 'package:flutter_application_stage_project/models/fields/update/dataFieldGroupUpdateResponse.dart';

import '../models/fields/datafieldsresponse.dart';
import '../models/fields/fileData.dart';
import '../services/ApiField.dart';
import '../services/ApiFieldGroup.dart';
import '../services/ApiFieldPost.dart';
import 'homeNavigate_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditElment extends StatefulWidget {
  final String title;
  final String family_id;
  final String Element_id;
  const EditElment(
      {required this.title,
      required this.family_id,
      required this.Element_id,
      super.key});

  @override
  State<EditElment> createState() => _EditElmentState();
}

class _EditElmentState extends State<EditElment> {
  List<DataFields> data = [];
  Map<String, List<DataFieldGroupUpdate>> dataGroupMap = {};
  final TextEditingController emailController = TextEditingController();
  Map<String, dynamic> fieldValues = {};
  Map<String, bool> fieldDataFetchedMap = {};
  List<String> fetchedGroupIds = [];

  @override
  void initState() {
    super.initState();
    fetchData(widget.family_id);
  }

  Future<void> fetchData(String id) async {
    try {
      DataFieldRespone fetchedData = await ApiFieldGroup.getGroupfields(id);
      setState(() {
        data = fetchedData.data
            .map((field) => DataFields(
                  id: field.id,
                  label: field.label,
                  isExpanded: false,
                ))
            .toList();
        loading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des données : $e');
    }
  }

  Future<void> fetchFeildData(String groupId) async {
    if (fetchedGroupIds.contains(groupId)) {
      // Si les données pour ce groupe ont déjà été récupérées, ne lancez pas d'appel API redondant
      return;
    }

    try {
      DataFieldGroupUpdateResponse fetchDataGroup =
          await ApiField.getFeildsDataToUpdate(groupId, widget.Element_id);

      setState(() {
        dataGroupMap[groupId] = fetchDataGroup.data;
        fetchedGroupIds
            .add(groupId); // Ajoutez l'ID du groupe aux groupes récupérés
      });
    } catch (e) {
      print('Failed to fetch feild data  : $e');
    }
  }

  final _formKey = GlobalKey<FormState>();
  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit a ${widget.title}")),
      body: loading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  children: [
                    ExpansionPanelList(
                      expandIconColor: Colors.blue,
                      dividerColor: Colors.grey,
                      expansionCallback: (panelIndex, isExpanded) {
                        final groupId = data[panelIndex].id.toString();
                        if (!isExpanded && !dataGroupMap.containsKey(groupId)) {
                          fetchFeildData(groupId);
                        }
                        setState(() {
                          data[panelIndex].isExpanded = !isExpanded;
                        });
                      },
                      children: data.map<ExpansionPanel>((DataFields item) {
                        return ExpansionPanel(
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              title: Text(
                                item.label,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onTap: () {},
                            );
                          },
                          body: dataGroupMap[item.id.toString()]?.isEmpty ??
                                  true
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Column(
                                  children: dataGroupMap[item.id.toString()]!
                                      .map((groupfield) {
                                    log("+++++++++++++++++++++++++" +
                                        groupfield.toString());

                                    return Container(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      child: FieldWidgetGeneratorUpdate(
                                        dataFieldGroup: groupfield,
                                        emailController: emailController,
                                        formMap: fieldValues,
                                      ),
                                    );
                                  }).toList(),
                                ),
                          isExpanded: item.isExpanded,
                        );
                      }).toList(),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        log(fieldValues.toString());

                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });
                          _formKey.currentState!.save();
                          try {
                            final postUpdate =
                                await ApiFieldPost.fieldUpdatePost(
                                    fieldValues, widget.Element_id);

                            print("Response: $postUpdate");
                            setState(() {
                              loading = false;
                            });

                            if (postUpdate == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green,
                                  action: SnackBarAction(
                                      label: "Ok",
                                      onPressed: () {
                                        if (widget.family_id == "6") {
                                          Navigator.pushAndRemoveUntil<dynamic>(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) =>
                                                  HomeNavigate(
                                                id_page: 2,
                                              ),
                                            ),
                                            (route) =>
                                                false, //if you want to disable back feature set to false
                                          );
                                        } else if (widget.family_id == "7") {
                                          Navigator.pushAndRemoveUntil<dynamic>(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) =>
                                                  HomeNavigate(
                                                id_page: 4,
                                              ),
                                            ),
                                            (route) =>
                                                false, //if you want to disable back feature set to false
                                          );
                                        } else if (widget.family_id == "3") {
                                          Navigator.pushAndRemoveUntil<dynamic>(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) =>
                                                  HomeNavigate(
                                                id_page: 3,
                                              ),
                                            ),
                                            (route) =>
                                                false, //if you want to disable back feature set to false
                                          );
                                        }
                                      }),
                                  content: Text('Form submitted successfully!'),
                                ),
                              );
                            } else if (postUpdate == 500) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.purple[200],
                                  action: SnackBarAction(
                                      label: "Ok", onPressed: () {}),
                                  content: Text(
                                      'Please check the validations of your required fields.'),
                                ),
                              );
                            }
                          } catch (e) {
                            print("Error $e");
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.purple[200],
                              action:
                                  SnackBarAction(label: "Ok", onPressed: () {}),
                              content: Text(
                                  'Please check the validations of your required fields.'),
                            ),
                          );
                        }
                      },
                      child: Text("Save"),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
