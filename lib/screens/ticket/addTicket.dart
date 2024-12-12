// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/bookings/bookings_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_application_stage_project/services/ApiFieldGroup.dart';
import 'package:flutter_application_stage_project/services/ApiFieldPost.dart';
import '../../core/constants/FieldWidgetGenerator.dart';
import '../../models/fields/datafieldgroup.dart';
import '../../models/fields/datafieldgroupresponse.dart';
import '../../models/fields/datafieldsresponse.dart';
import '../../models/fields/fileData.dart';
import '../../services/ApiField.dart';

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
            body: Container(
                child: Center(
                    child: CircularProgressIndicator(
            color: Colors.blue,
          ))))
        : Scaffold(
            appBar: AppBar(
              /*
              leading: IconButton(
                  onPressed: () {
                    if (widget.family_id == "6") {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => HomeNavigate(
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
                          builder: (BuildContext context) => HomeNavigate(
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
                          builder: (BuildContext context) => HomeNavigate(
                            id_page: 3,
                          ),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                    }else if (widget.family_id == "8") {
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => HomeNavigate(
                            id_page: 6,
                          ),
                        ),
                        (route) =>
                            false, //if you want to disable back feature set to false
                      );
                    }
                  },
                  icon: Icon(Icons.arrow_back)),
                  */
              title: Text(
                  "${AppLocalizations.of(context)!.add_a} ${widget.titel}"),
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
                              title: Text(
                                item.label,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            );
                          },
                          body: dataGroupMap[item.id.toString()]?.isEmpty ??
                                  true
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue, // Changer la couleur de fond ici
                      ),
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
                            // Add delay to show SnackBar

                            if (fielPostResponse == 200) {
                              await Future.delayed(Duration(seconds: 0));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green,
                                  action: SnackBarAction(
                                      textColor: Colors.white,
                                      label: "Ok",
                                      onPressed: () {}),
                                  content: Text(
                                      "${AppLocalizations.of(context)!.formsubmittedsuccessfully}"),
                                ),
                              );
                              if (widget.family_id == "6") {
                                /*
                                Navigator.pushAndRemoveUntil<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          TicketPage()),
                                  (route) => true,
                                );*/
                                Navigator.pop(context, true);
                              } else if (widget.family_id == "7") {
                                /*
                                Navigator.pushAndRemoveUntil<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          /*
                                        HomeNavigate(
                                      id_page: 4,
                                    ),
                                    */
                                          ProjectPage()),
                                  (route) => false,
                                );*/
                                Navigator.pop(context, true);
                              } else if (widget.family_id == "3") {
                                /*
                                Navigator.pushAndRemoveUntil<dynamic>(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                      builder: (BuildContext context) =>
                                          DealPage()),
                                  (route) => false,
                                );*/
                                Navigator.pop(context, true);
                              } else if (widget.family_id == "8") {
                                Navigator.pop(context, true);
                              }
                            } else if (fielPostResponse == 500) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
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
                                'Please check the validations for your required fields.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text("${AppLocalizations.of(context)!.save}"),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
