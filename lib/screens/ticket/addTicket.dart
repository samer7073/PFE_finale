import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/project/Project_page.dart';
import 'package:flutter_application_stage_project/screens/homeNavigate_page.dart';
import 'package:flutter_application_stage_project/screens/ticket/ticket_page.dart';
import 'package:flutter_application_stage_project/services/ApiFieldGroup.dart';
import 'package:flutter_application_stage_project/services/ApiFieldPost.dart';

import '../../core/constants/FieldWidgetGenerator.dart';
import '../../models/fields/datafieldgroup.dart';
import '../../models/fields/datafieldgroupresponse.dart';
import '../../models/fields/datafieldsresponse.dart';
import '../../models/fields/fileData.dart';
import '../../services/ApiField.dart';
import '../loading.dart';

class AddElement extends StatefulWidget {
  final String family_id;
  final String titel;

  const AddElement({required this.family_id, required this.titel, Key? key})
      : super(key: key);

  @override
  State<AddElement> createState() => _AddElementState();
}

class _AddElementState extends State<AddElement> {
  List<DataFields> data = [];
  Map<String, List<DataFieldGroup>> dataGroupMap = {};
  final TextEditingController emailController = TextEditingController();
  Map<String, dynamic> fieldValues = {};
  Map<String, bool> fieldDataFetchedMap = {};
  List<String> fetchedGroupIds = [];
  bool loading = true;

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
            .asMap()
            .map((index, field) => MapEntry(
                  index,
                  DataFields(
                    id: field.id,
                    label: field.label,
                    isExpanded: index == 0, // Only expand the first panel
                  ),
                ))
            .values
            .toList();
        loading = false;
        fetchFeildData(data[0].id.toString());
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
      DataFieldGroupResponse fetchDataGroup =
          await ApiField.getFeildsData(groupId);

      setState(() {
        dataGroupMap[groupId] = fetchDataGroup.data;
        fetchedGroupIds
            .add(groupId); // Ajoutez l'ID du groupe aux groupes récupérés
      });
    } catch (e) {
      print('Failed to fetch  : $e');
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
            body: Container(child: Center(child: CircularProgressIndicator())))
        : Scaffold(
            appBar: AppBar(
              title: Text("Add a ${widget.titel}"),
            ),
            body: SingleChildScrollView(
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  children: [
                    ExpansionPanelList(
                      expandIconColor: Colors.blue,
                      dividerColor: Colors.grey,
                      expandedHeaderPadding:
                          EdgeInsets.all(0), // Optional: adjust padding
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
                              title: Text(item.label),
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
                                    return Container(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      child: FieldWidgetGenerator(
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
                        print(fieldValues.toString());
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            loading = true;
                          });
                          try {
                            final fielPostResponse =
                                await ApiFieldPost.fieldPost(
                                    fieldValues, int.parse(widget.family_id));
                            print("Response: $fielPostResponse");
                            setState(() {
                              loading = false;
                            });
                            if (fielPostResponse == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green,
                                  action: SnackBarAction(
                                      label: "Ok",
                                      onPressed: () {
                                        log(widget.family_id);
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
                            } else if (fielPostResponse == 500) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green,
                                  action: SnackBarAction(
                                      textColor: Colors.white,
                                      label: "Ok",
                                      onPressed: () {}),
                                  content: Text(
                                      'Please check the validations for your required fields.'),
                                ),
                              );
                            }
                          } catch (e) {
                            print("Error $e");
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.orange,
                              action:
                                  SnackBarAction(label: "Ok", onPressed: () {}),
                              content: Text(
                                  'Please check the validations for your required fields.'),
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
