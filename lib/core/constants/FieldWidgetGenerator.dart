// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/fields/datafieldgroup.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../services/ApiFamilyModuleData.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class FieldWidgetGenerator extends StatefulWidget {
  final DataFieldGroup dataFieldGroup;
  final TextEditingController? emailController;
  final Map<String, dynamic> formMap;

  const FieldWidgetGenerator({
    required this.dataFieldGroup,
    this.emailController,
    required this.formMap,
    Key? key,
  }) : super(key: key);

  @override
  _FieldWidgetGeneratorState createState() => _FieldWidgetGeneratorState();
}

class _FieldWidgetGeneratorState extends State<FieldWidgetGenerator> {
  bool? _valueChecked = false;
  List<bool?> _valuesChecked = [];
  List<bool?> _valuesCheckedModule = [];
  String? _selectedRadio;
  int? _selectedRadioModule;
  String? optionAutocomplete;
  List<Map<String, dynamic>> _dropdownItems = [];
  List<Map<String, dynamic>> radioModule = [];
  List<Map<String, dynamic>> autocompleModule = [];
  List<Map<String, dynamic>> checkboxModule = [];
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _currencies = [];
  final List<Map<String, String>> colors = [
    {"label": "Black", "value": "#374151"},
    {"label": "Red", "value": "#dc2626"},
    {"label": "Orange", "value": "#f59e0b"},
    {"label": "Green", "value": "#10b981"},
    {"label": "Blue", "value": "#2563eb"},
    {"label": "BlueViolet", "value": "#4f46e5"},
    {"label": "Purple", "value": "#7c3aed"},
    {"label": "Pink", "value": "#ec4899"},
    {"label": "Gray", "value": "#9ca3af"}
  ];

  String droupDownValue = "Choisir un Elemnt";
  TextEditingController? _textEditingController;
  String? _selectedValue;
  List<dynamic> selectedValuesList = [];
  bool _isImageSelected = false;
  @override
  void initState() {
    super.initState();
    _valuesChecked = List.generate(
      widget.dataFieldGroup.listfieldsview.length,
      (index) => false,
    );
    // Pré-remplir la valeur sélectionnée pour le menu déroulant, si elle existe dans le formMap

/*
    _selectedValue =
        widget.formMap["field[${widget.dataFieldGroup.id.toString()}]"];*/
    // Utilisez un nouveau TextEditingController pour chaque champ de texte
    _textEditingController = TextEditingController();
    // Pré-remplissez le champ avec la valeur du formMap, si elle existe
    /*
    _textEditingController!.text =
        widget.formMap["field[${widget.dataFieldGroup.id.toString()}]"] ?? '';
        */
    if (widget.dataFieldGroup.field_type == "select") {
      fetchDropdownOptions(widget.dataFieldGroup.module);
    } else if (widget.dataFieldGroup.field_type == "country") {
      fetchCountries();
    } else if (widget.dataFieldGroup.field_type == "multiselect") {
      fetchDropdownOptions(widget.dataFieldGroup.module);
      log("i am in mutli select ----------------------------------------------");
    } else if (widget.dataFieldGroup.field_type == "monetary") {
      fetchCurrencies();
    } else if (widget.dataFieldGroup.field_type == 'radio' &&
        widget.dataFieldGroup.module != null) {
      fetchRadioModule(widget.dataFieldGroup.module!);
    } else if (widget.dataFieldGroup.field_type == 'checkbox' &&
        widget.dataFieldGroup.module != null) {
      fetchcheckboxModule(widget.dataFieldGroup.module);
    } else if (widget.dataFieldGroup.field_type == 'autocomplete' &&
        widget.dataFieldGroup.module != null) {
      fetchAutoComple(widget.dataFieldGroup.module);
    }
    // Ajoutez un écouteur pour écouter les changements de texte
    _textEditingController!.addListener(() {
      final value = _textEditingController!.text;
      final fieldId = widget.dataFieldGroup.id.toString();

      if (value.isEmpty) {
        // Supprimez la valeur de la map si le texte est vide
        widget.formMap.remove("field[$fieldId]");
      } else {
        // Mettez à jour la valeur dans la map
        widget.formMap["field[$fieldId]"] = value;
      }

      // Affichez la map dans les logs
      log(widget.formMap.toString());
    });
  }

  @override
  void dispose() {
    // Assurez-vous de libérer le TextEditingController lorsqu'il n'est plus utilisé
    _textEditingController!.dispose();
    super.dispose();
  }

  Future<void> fetchDropdownOptions(int moduleInt) async {
    try {
      String module = moduleInt.toString();
      List<dynamic> list =
          await ApiFamilyModuleData.getFamilyModuleData(module);
      setState(() {
        // Création d'une liste de Map contenant à la fois l'ID et le libellé
        _dropdownItems = list.map<Map<String, dynamic>>((option) {
          return {
            'id': option['id'].toString(), // Récupération de l'ID
            'label': option['label'].toString() // Récupération du libellé
          };
        }).toList();
        print("drop down iteme : $_dropdownItems");
      });
    } catch (e) {
      print('Failed to fetch Dropdown options : $e');
    }
  }

  Future<void> fetchAutoComple(int moduleInt) async {
    try {
      String module = moduleInt.toString();
      List<dynamic> list =
          await ApiFamilyModuleData.getFamilyModuleData(module);
      setState(() {
        // Création d'une liste de Map contenant à la fois l'ID et le libellé
        autocompleModule = list.map<Map<String, dynamic>>((option) {
          return {
            'id': option['id'], // Récupération de l'ID
            'label': option['label'].toString() // Récupération du libellé
          };
        }).toList();
        print("drop down iteme : $autocompleModule");
      });
    } catch (e) {
      print('Failed to fetch RadioModule options : $e');
    }
  }

  Future<void> fetchRadioModule(int moduleInt) async {
    try {
      String module = moduleInt.toString();
      List<dynamic> list =
          await ApiFamilyModuleData.getFamilyModuleData(module);
      setState(() {
        // Création d'une liste de Map contenant à la fois l'ID et le libellé
        radioModule = list.map<Map<String, dynamic>>((option) {
          return {
            'id': option['id'], // Récupération de l'ID
            'label': option['label'].toString() // Récupération du libellé
          };
        }).toList();
        print("drop down iteme : $radioModule");
      });
    } catch (e) {
      print('Failed to fetch RadioModule options : $e');
    }
  }

  Future<void> fetchcheckboxModule(int moduleInt) async {
    try {
      String module = moduleInt.toString();
      List<dynamic> list =
          await ApiFamilyModuleData.getFamilyModuleData(module);
      setState(() {
        // Création d'une liste de Map contenant à la fois l'ID et le libellé
        checkboxModule = list.map<Map<String, dynamic>>((option) {
          return {
            'id': option['id'], // Récupération de l'ID
            'label': option['label'].toString() // Récupération du libellé
          };
        }).toList();
        print("drop down iteme : $checkboxModule");
        _valuesCheckedModule = List<bool?>.filled(checkboxModule.length, false);
      });
    } catch (e) {
      print('Failed to fetch Dropdown options : $e');
    }
  }

  Future<void> fetchCountries() async {
    try {
      List<dynamic> listCountries = await ApiFamilyModuleData.getCountries();
      setState(() {
        // Création d'une liste de Map contenant à la fois l'ID et le libellé
        _countries = listCountries.map<Map<String, dynamic>>((option) {
          return {
            'id': option['id'].toString(), // Récupération de l'ID
            'label': option['label'].toString() // Récupération du libellé
          };
        }).toList();
        print("${_countries.toString()}");
      });
    } catch (e) {
      print('Failed to fetch Dropdown Countries options : $e');
    }
  }

  Future<void> fetchCurrencies() async {
    try {
      List<dynamic> listcurrencies = await ApiFamilyModuleData.getCurrencies();
      setState(() {
        // Création d'une liste de Map contenant à la fois l'ID et le libellé
        _currencies = listcurrencies.map<Map<String, dynamic>>((option) {
          return {
            'currency': option['currency'].toString(), // Récupération de l'ID
            'currency_symbol': option['currency'].toString() +
                "(" +
                option['currency_symbol'] +
                ")" // Récupération du libellé
          };
        }).toList();
        log("${_countries}");
      });
    } catch (e) {
      print('Failed to fetch Dropdown Currencies options : $e');
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  XFile? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 100, maxWidth: 100);
    if (pickedImage != null) {
      setState(() {
        _imageFile = pickedImage;

        // log("$_imageFile");
      });
      final imageBytes = await _imageFile!.readAsBytes();
      String fileName = _imageFile!.path.split('/').last;

      widget.formMap["field[${widget.dataFieldGroup.id.toString()}]"] =
          MultipartFile.fromBytes(imageBytes, filename: fileName);
      log("${widget.formMap.toString()}");
    }
  }

  List<XFile>? imageFileList = [];
  void selectedImages() async {
    final picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();
    if (selectedImages != null && selectedImages.isNotEmpty) {
      int count = 0;
      for (XFile imageFile in selectedImages) {
        final imageBytes = await imageFile.readAsBytes();
        String fileName = imageFile.path.split('/').last;

        // Vous pouvez appliquer ici les opérations spécifiques à chaque image
        // Comme l'ajout à une liste, la mise à jour de l'état, ou l'envoi vers un serveur

        widget.formMap[
                "field[${widget.dataFieldGroup.id.toString()}][$count]"] =
            MultipartFile.fromBytes(imageBytes, filename: fileName);
        log("${widget.formMap.toString()}");
        count++;
      }
      count = 0;

      // Vous pouvez également ajouter les images sélectionnées à votre liste imageFileList si nécessaire
      imageFileList!.addAll(selectedImages);

      setState(() {});
    }
  }

  List<File> fileList = [];

  void selectFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        fileList = result.paths.map((path) => File(path!)).toList();
      });

      int count = 0;
      for (File file in fileList) {
        final FileBytes = await file.readAsBytes();
        String fileName = file.path.split('/').last;
        widget.formMap[
                "field[${widget.dataFieldGroup.id.toString()}][$count]"] =
            MultipartFile.fromBytes(FileBytes, filename: fileName);
        log("${widget.formMap.toString()}");
        count++;
      }
    }
  }

  String? _selectedItem;
  Widget customDatePickerBuilder(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.blue, // Couleur de fond de l'en-tête

        colorScheme: ColorScheme.light(
          primary: Colors.blue, // Couleur de fond de l'en-tête
          onPrimary: Colors.white, // Couleur du texte de l'en-tête
          surface: Colors.pink, // Couleur de fond du calendrier
          onSurface: Colors.black, // Couleur du texte
        ),
        dialogBackgroundColor:
            Colors.white, // Couleur de fond de la boîte de dialogue
      ),
      child: child!,
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.dataFieldGroup.field_type) {
      case 'autocomplete':
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: FormField(
            onSaved: (newValue) {
              log("----------------" + newValue.toString());
            },
            builder: (state) {
              return Column(
                children: [
                  Autocomplete<String>(
                    fieldViewBuilder: (context, textEditingController,
                        focusNode, onFieldSubmitted) {
                      return TextFormField(
                        validator: (value) {
                          log("validtour value : $value");
                          final isOptionSelected = autocompleModule
                              .any((item) => item['label'] == value);

                          log(isOptionSelected.toString());
                          if (isOptionSelected == false && value!.isNotEmpty) {
                            return "Veuillez sélectionner une option valide";
                          } else {
                            null;
                          }
                        },
                        onChanged: (value) {
                          log("-----------" + value.toString());
                          // Check if the value is empty, if yes, remove the corresponding entry from the map
                          if (value.isEmpty || value != optionAutocomplete) {
                            widget.formMap.remove(
                                "field[${widget.dataFieldGroup.id.toString()}]");
                          }
                        },
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.red),
                          constraints: BoxConstraints(),
                          labelStyle: TextStyle(color: Colors.grey),
                          hintStyle: TextStyle(color: Colors.grey),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.5),
                          ),
                          contentPadding: EdgeInsets.all(10),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 233, 242, 247)
                              .withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey), // Couleur du bord
                          ),
                          labelText: widget.dataFieldGroup.alias,
                          hintText: "choisir un elment",
                        ),
                      );
                    },
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return Iterable<String>.empty();
                      }
                      return autocompleModule
                          .where((Map<String, dynamic> item) => item['label']
                              .toString()
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()))
                          .map<String>((item) => item['label'].toString())
                          .toList();
                    },
                    onSelected: (option) {
                      setState(() {
                        optionAutocomplete = option;
                        log(optionAutocomplete
                            .toString()); // Show selected value in
                      });
                      // Find the selected item in autocompleModule
                      final selectedItem = autocompleModule.firstWhere(
                          (item) => item['label'].toString() == option);
                      final selectedId = selectedItem[
                          'id']; // Extract the ID from the selected item
                      log('Selected Label: $option, Selected ID: $selectedId');
                      widget.formMap[
                              "field[${widget.dataFieldGroup.id.toString()}]"] =
                          selectedId;
                      log(widget.formMap.toString());
                      // Call state.didChange to notify the FormField of the change
                      state.didChange(selectedId);
                    },
                  ),
                  Text(
                    state.errorText ?? "",
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                    ),
                  ),
                ],
              );
            },
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    // Add your validation logic here
                    // For example, you can check if a value is selected
                    if (value == null) {
                      return 'Vous devez sélectionner une option';
                    }
                    return null; // Return null if validation succeeds
                  }
                : null,
          ),
        );

      case "email":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            controller: _textEditingController,
            onChanged: (newValue) {
              // Mettez à jour la carte lorsque la valeur change
              setState(() {
                widget.formMap[
                    "field[${widget.dataFieldGroup.id.toString()}]"] = newValue;
              });
            },
            decoration: DecorationTextFormField(),
            keyboardType: TextInputType.emailAddress,
          ),
        );
      case "phone":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            controller: _textEditingController,
            keyboardType: TextInputType.phone,
            decoration: DecorationTextFormField(),
            onChanged: (newValue) {
              // Mettez à jour la carte lorsque la valeur change
              setState(() {
                widget.formMap[
                    "field[${widget.dataFieldGroup.id.toString()}]"] = newValue;
              });
            },
          ),
        );
      case "range":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            readOnly: true,
            controller: _textEditingController,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.5)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.5)),
              labelText: widget.dataFieldGroup.alias,
              hintText: "Search",
              suffix: IconButton(
                onPressed: () {
                  _textEditingController!
                      .clear(); // Efface la valeur du contrôleur
                  widget.formMap.remove(
                      "field[${widget.dataFieldGroup.id.toString()}][0]");
                  widget.formMap.remove(
                      "field[${widget.dataFieldGroup.id.toString()}][1]");
                  log(widget.formMap.toString());
                },
                icon: Icon(Icons.cancel),
              ),
              prefixIcon: IconButton(
                  onPressed: () async {
                    var timeSelected = await showDateRangePicker(
                        builder: customDatePickerBuilder,
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(3000));
                    print(timeSelected);
                    if (timeSelected != null) {
                      String formattedStart =
                          DateFormat('dd-MM-yyyy').format(timeSelected.start);
                      print(formattedStart);

                      String formattedEnd =
                          DateFormat('dd-MM-yyyy').format(timeSelected.end);
                      print(formattedEnd);
                      widget.formMap[
                              "field[${widget.dataFieldGroup.id.toString()}][0]"] =
                          formattedStart;
                      widget.formMap[
                              "field[${widget.dataFieldGroup.id.toString()}][1]"] =
                          formattedEnd;
                      log(widget.formMap.toString());
                      setState(() {
                        _textEditingController?.text =
                            "$formattedStart - $formattedEnd";
                      });
                    }
                  },
                  icon: Icon(Icons.date_range)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            ),
          ),
        );
      case "time":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            readOnly: true,
            controller: _textEditingController,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.5)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.5)),
              labelText: widget.dataFieldGroup.alias,
              hintText: "Search",
              suffix: IconButton(
                onPressed: () {
                  _textEditingController!
                      .clear(); // Efface la valeur du contrôleur
                  widget.formMap
                      .remove("field[${widget.dataFieldGroup.id.toString()}]");
                  log(widget.formMap.toString());
                },
                icon: Icon(Icons.cancel),
              ),
              prefixIcon: IconButton(
                  onPressed: () async {
                    TimeOfDay? timeOfDay = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: 00, minute: 00),
                        builder: customDatePickerBuilder);
                    if (timeOfDay != null) {
                      // Vérifiez si l'heure sélectionnée n'est pas nulle
                      String formattedTime = _formatTimeOfDay(timeOfDay);
                      print(formattedTime);
                      setState(() {
                        _textEditingController?.text = formattedTime;
                      });
                      widget.formMap[
                              "field[${widget.dataFieldGroup.id.toString()}]"] =
                          formattedTime;
                      log(widget.formMap.toString());
                    }
                  },
                  icon: Icon(Icons.date_range)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            ),
          ),
        );
      case "date_time":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            readOnly: true,
            controller: _textEditingController,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.5)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.5)),
              labelText: widget.dataFieldGroup.alias,
              hintText: "Search",
              suffixIcon: IconButton(
                onPressed: () {
                  _textEditingController!
                      .clear(); // Efface la valeur du contrôleur
                  widget.formMap
                      .remove("field[${widget.dataFieldGroup.id.toString()}]");
                  log(widget.formMap.toString());
                },
                icon: Icon(
                  Icons.cancel,
                  size: 20,
                ),
              ),
              prefixIcon: IconButton(
                  onPressed: () async {
                    DateTime? dateTime = await showOmniDateTimePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(3000),
                      theme: ThemeData(
                        primaryColor: Colors.blue,
                        colorScheme: ColorScheme.light(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          surface: Colors.pink,
                          onSurface: Colors.black,
                        ),
                        dialogBackgroundColor: Colors.white,
                      ),
                    );

                    if (dateTime != null) {
                      // Vérifiez si la date et l'heure sélectionnées ne sont pas nulles

                      String formattedDateTime =
                          DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
                      setState(() {
                        _textEditingController?.text = formattedDateTime;
                      });

                      widget.formMap[
                              "field[${widget.dataFieldGroup.id.toString()}]"] =
                          formattedDateTime;
                      log(widget.formMap.toString());
                    }
                  },
                  icon: Icon(
                    color: Colors.blue,
                    Icons.date_range,
                    size: 20,
                  )),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
            ),
          ),
        );
      case "date":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            readOnly: true,
            controller: _textEditingController,
            decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.grey),
              hintStyle: TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.5)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.5)),
              labelText: widget.dataFieldGroup.alias,
              hintText: "Search",
              suffixIcon: _textEditingController!.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _textEditingController!.clear();
                        widget.formMap.remove(
                            "field[${widget.dataFieldGroup.id.toString()}]");
                        log(widget.formMap.toString());
                      },
                      icon: Icon(
                        Icons.cancel,
                        color: Colors.blue,
                      ),
                    )
                  : null,
              prefixIcon: IconButton(
                color: Colors.blue,
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(3000),
                    builder: customDatePickerBuilder,
                  );
                  if (picked != null) {
                    // Vérifiez si la date sélectionnée n'est pas nulle
                    String formattedDate =
                        DateFormat('dd-MM-yyyy').format(picked);
                    setState(() {
                      _textEditingController?.text = formattedDate;
                    });

                    print(formattedDate);
                    widget.formMap[
                            "field[${widget.dataFieldGroup.id.toString()}]"] =
                        formattedDate;
                    log(widget.formMap.toString());
                  }
                },
                icon: Icon(Icons.date_range),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 12.0,
              ), // Ajustez cette ligne pour réduire la hauteur
            ),
          ),
        );

      case "image":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: FormField(
            builder: (state) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${widget.dataFieldGroup.alias}",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      ElevatedButton.icon(
                        icon: Icon(Icons.image_outlined),
                        onPressed: () async {
                          _pickImage();
                        },
                        label: Text("Upload"),
                      ),
                    ],
                  ),
                  _imageFile == null
                      ? Text('')
                      : ListTile(
                          leading: Image.file(File(_imageFile!.path)),
                          title: Text("${_imageFile!.path.split('/').last}"),
                          trailing: IconButton(
                            onPressed: () {
                              // Supprimer l'élément de la liste fileList
                              setState(() {
                                _imageFile = null;
                                widget.formMap.remove(
                                    "field[${widget.dataFieldGroup.id.toString()}]");
                                log(widget.formMap.toString());
                              });
                            },
                            icon: Icon(Icons.delete_outline),
                            tooltip: 'Supprimer',
                          ),
                        ),
                  Text(
                    state.errorText ??
                        "", // Affiche l'erreur seulement si aucune image n'est sélectionnée et que le champ est obligatoire
                    style: TextStyle(
                      color: Theme.of(context).errorColor,
                    ),
                  )
                ],
              );
            },
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (_imageFile == null) {
                      return 'Ce champ est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
          ),
        );
      case "album":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: FormField(
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.dataFieldGroup.alias}",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        ElevatedButton.icon(
                            icon: Icon(Icons.photo_album_outlined),
                            onPressed: () {
                              selectedImages();
                            },
                            label: Text("Upload")),
                      ],
                    ),
                    Container(
                        height: imageFileList == null
                            ? 0
                            : imageFileList!.length * 50,
                        child: imageFileList == null
                            ? Text("")
                            : ListView.builder(
                                itemCount: imageFileList!.length,
                                itemBuilder: (context, index) {
                                  final album = imageFileList![index].path;
                                  return ListTile(
                                    leading: Image.file(File(album)),
                                    title: Text(album.split('/').last),
                                    trailing: IconButton(
                                      onPressed: () {
                                        // Supprimer l'élément de la liste fileList
                                        setState(() {
                                          imageFileList?.removeAt(index);
                                          widget.formMap.remove(
                                              "field[${widget.dataFieldGroup.id.toString()}][$index]");
                                          log(widget.formMap.toString());
                                        });
                                      },
                                      icon: Icon(Icons.delete_outline),
                                      tooltip: 'Supprimer',
                                    ),
                                  );
                                },
                              )),
                    Text(
                      state.errorText ?? "",
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                      ),
                    )
                  ],
                );
              },
              validator: widget.dataFieldGroup.required == true
                  ? (value) {
                      if (imageFileList == null || imageFileList!.isEmpty) {
                        return 'Vous devez sélectionner au moins un terme';
                      } else {
                        return null;
                      }
                    }
                  : null),
        );

      case "file":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: FormField(
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.dataFieldGroup.alias}",
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        ElevatedButton.icon(
                            icon: Icon(Icons.upload_file_outlined),
                            onPressed: () {
                              selectFiles();
                            },
                            label: Text("Upload")),
                      ],
                    ),
                    Text(
                      state.errorText ?? "",
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                    Container(
                      height: fileList == null
                          ? 0
                          : fileList.length *
                              50, // Assurez-vous que cette hauteur est suffisante
                      child: fileList == null || fileList.isEmpty
                          ? Text("Aucun fichier sélectionné")
                          : ListView.builder(
                              itemCount: fileList
                                  .length, // Utilisation de fileList.length comme itemCount
                              itemBuilder: (context, index) {
                                final file =
                                    fileList[index].path.split('/').last;
                                return ListTile(
                                  title: Text('${file}'),
                                  trailing: IconButton(
                                    onPressed: () {
                                      // Supprimer l'élément de la liste fileList
                                      setState(() {
                                        fileList.removeAt(index);
                                        widget.formMap.remove(
                                            "field[${widget.dataFieldGroup.id.toString()}][${index}]");
                                        log(widget.formMap.toString());
                                      });
                                    },
                                    icon: Icon(Icons.delete_outline),
                                    tooltip: 'Supprimer',
                                  ),
                                );
                              },
                            ),
                    )
                  ],
                );
              },
              validator: widget.dataFieldGroup.required == true
                  ? (value) {
                      if (fileList == null || fileList!.isEmpty) {
                        return 'Vous devez sélectionner au moins un terme';
                      } else {
                        return null;
                      }
                    }
                  : null),
        );

      case "password":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            controller: _textEditingController,
            obscureText: true,
            decoration: DecorationTextFormField(),
          ),
        );
      case "rate":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
            child: FormField(
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dataFieldGroup.alias,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                        widget.formMap[
                                "field[${widget.dataFieldGroup.id.toString()}]"] =
                            rating.toString();
                        log(widget.formMap.toString());
                        // Appeler state.didChange pour notifier le FormField qu'il y a eu un changement
                        state.didChange(rating);
                      },
                    ),
                    Text(
                      state.errorText ?? "",
                      style: TextStyle(
                        color: Theme.of(context).errorColor,
                      ),
                    )
                  ],
                );
              },
              validator: widget.dataFieldGroup.required == true
                  ? (value) {
                      // Ajoutez votre logique de validation ici
                      // Par exemple, vous pouvez vérifier si une note minimale est attribuée
                      if (value == null) {
                        return 'Vous devez attribuer une note';
                      }
                      return null; // Retourne null si la validation réussit
                    }
                  : null,
            ),
          ),
        );

      case "color":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                widget.dataFieldGroup.alias,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButtonFormField(
              hint: Container(
                width: 100,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Select " + widget.dataFieldGroup.alias,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ),
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.grey),
                hintStyle: TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.5)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.5)),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              ),
              value: _selectedValue,
              validator: widget.dataFieldGroup.required == true
                  ? (value) {
                      if (value == null) {
                        return 'Please select an option';
                      }
                    }
                  : null,

              onChanged: (value) {
                setState(() {
                  _selectedItem = value;
                  _selectedValue = value as String?;
                  widget.formMap[
                      "field[${widget.dataFieldGroup.id.toString()}]"] = value;
                });
                log(widget.formMap.toString() + "\n");
              },
              elevation: 0,
              isDense:
                  true, // Set isDense to true to reduce the vertical size of the DropdownButtonFormField
              menuMaxHeight: 200,
              padding: EdgeInsets.symmetric(
                  vertical: 8, horizontal: 12), // Adjust padding as needed
              borderRadius:
                  BorderRadius.circular(8), // Adjust border radius as needed
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black), // Adjust font size as needed
              items: colors.map<DropdownMenuItem<String>>((color) {
                return DropdownMenuItem<String>(
                  value: color['value'],
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      color['label']!,
                      style:
                          TextStyle(fontSize: 14), // Adjust font size as needed
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_selectedItem != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedValue = null; // Désélection de l'item
                        _selectedItem = null;
                        final fieldId = widget.dataFieldGroup.id.toString();
                        widget.formMap.remove("field[$fieldId]");
                      });
                    },
                    child: Text(
                      'Deselect',
                      style: TextStyle(
                        color: Colors.red, // Couleur du texte
                        fontSize: 16, // Taille de police
                        fontWeight: FontWeight.bold, // Gras
                        // Autres styles que vous souhaitez appliquer
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );

      case "link":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            controller: _textEditingController,
            keyboardType: TextInputType.url,
            decoration: DecorationTextFormField(),
            onChanged: (newValue) {
              // Mettez à jour la carte lorsque la valeur change
              setState(() {
                widget.formMap[
                    "field[${widget.dataFieldGroup.id.toString()}]"] = newValue;
              });
            },
          ),
        );
      case "monetary":
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButtonFormField(
                      validator: widget.dataFieldGroup.required == true
                          ? (value) {
                              if (value == null) {
                                return 'Please select an option';
                              }
                            }
                          : null,
                      value: _selectedValue,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.grey),
                        hintStyle: TextStyle(color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.5)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.5)),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 2.0),
                      ),
                      onChanged: (value) {
                        log("gggggggggggggggggggggggggggggggggggg");
                        setState(() {
                          _selectedItem = value;
                          _selectedValue = value;
                          log(value.toString());
                          widget.formMap[
                                  "field[${widget.dataFieldGroup.id.toString()}][0]"] =
                              value;
                        });
                        log(widget.formMap.toString());
                      },
                      elevation: 8,
                      isDense: false,
                      menuMaxHeight: 200,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      borderRadius: BorderRadius.circular(10),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      items: _currencies.map<DropdownMenuItem<String>>((item) {
                        return DropdownMenuItem<String>(
                          alignment: Alignment.center,
                          enabled: true,
                          value: item['currency'],
                          child: Row(
                            children: [
                              //SizedBox(width: 50, child: Text(item['currency'])),
                              Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text("${item['currency_symbol']}"))
                            ],
                          ),
                        );
                      }).toList()
                      //value: droupDownValue,
                      ),
                ),
                Expanded(
                  child: TextFormField(
                    validator: widget.dataFieldGroup.required == true
                        ? (value) {
                            if (value!.isEmpty) {
                              return 'Ce champs est obligatoire';
                            } else {
                              return null;
                            }
                          }
                        : null,
                    // Si le champ n'est pas requis, le validateur est null
                    //controller: _textEditingController,
                    keyboardType: TextInputType.number,
                    decoration: DecorationTextFormField(),
                    onChanged: (value) {
                      widget.formMap[
                              "field[${widget.dataFieldGroup.id.toString()}][1]"] =
                          value;
                      log(widget.formMap.toString());
                    },
                  ),
                ),
              ],
            ),
            if (_selectedItem != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedValue = null; // Désélection de l'item
                        _selectedItem = null;
                        final fieldId = widget.dataFieldGroup.id.toString();
                        widget.formMap.remove("field[$fieldId][0]");
                      });
                    },
                    child: Text(
                      'Deselect',
                      style: TextStyle(
                        color: Colors.red, // Couleur du texte
                        fontSize: 16, // Taille de police
                        fontWeight: FontWeight.bold, // Gras
                        // Autres styles que vous souhaitez appliquer
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );

      case "country":
        //fetchCountries();
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.dataFieldGroup.alias}",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                DropdownButtonFormField(
                    hint: Container(
                      width: 200,
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          "Select " + widget.dataFieldGroup.alias,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    value: _selectedValue,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.grey),
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.5)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.5)),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                    ),
                    validator: widget.dataFieldGroup.required == true
                        ? (value) {
                            if (value == null) {
                              return 'Please select an option';
                            }
                          }
                        : null,
                    onChanged: (value) {
                      setState(() {
                        _selectedItem = value;
                        _selectedValue = value as String;
                        print(value);
                        widget.formMap[
                                "field[${widget.dataFieldGroup.id.toString()}]"] =
                            value;
                        log("message");
                        log(widget.formMap.toString());
                      });
                    },
                    padding: EdgeInsets.fromLTRB(5, 10, 2, 10),
                    borderRadius: BorderRadius.circular(10),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    items: _countries.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'],
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            item['label'],
                            style: TextStyle(),
                          ),
                        ),
                      );
                    }).toList()
                    //value: droupDownValue,
                    ),
                if (_selectedItem != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedValue = null; // Désélection de l'item
                            _selectedItem = null;
                            final fieldId = widget.dataFieldGroup.id.toString();
                            widget.formMap.remove("field[$fieldId]");
                            log(widget.formMap.toString());
                          });
                        },
                        child: Text(
                          'Deselect',
                          style: TextStyle(
                            color: Colors.red, // Couleur du texte
                            fontSize: 16, // Taille de police
                            fontWeight: FontWeight.bold, // Gras
                            // Autres styles que vous souhaitez appliquer
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );

      case "multiselect":
        if (widget.dataFieldGroup.listfieldsview.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: MultiSelectDialogField(
              buttonText: Text("Select " + widget.dataFieldGroup.alias),
              title: Text(widget.dataFieldGroup.alias),
              buttonIcon: Icon(
                Icons.arrow_drop_down_outlined,
                color: Colors.black,
              ),
              validator: widget.dataFieldGroup.required == true
                  ? (value) {
                      if (value == null) {
                        return 'Please select an option';
                      }
                    }
                  : null,
              initialValue: selectedValuesList,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)),
              itemsTextStyle: Theme.of(context).textTheme.bodyText1,
              selectedItemsTextStyle: Theme.of(context).textTheme.bodyText1,
              selectedColor: Colors.blue,
              items: _dropdownItems
                  .map((item) => MultiSelectItem(item['id'], item['label']))
                  .toList(),
              listType: MultiSelectListType.LIST,
              onConfirm: (values) {
                setState(() {
                  selectedValuesList = values;
                  log(selectedValuesList.toString());
                });
                log(values.toString());
                // Stocker les valeurs sélectionnées dans widget.formMap avec des clés sans indices
                List<String> keysToRemove = widget.formMap.keys
                    .where((key) => key.startsWith(
                        "field[${widget.dataFieldGroup.id.toString()}]"))
                    .toList();

                for (var key in keysToRemove) {
                  widget.formMap.remove(key);
                }
                int index = 0;
                for (var value in values) {
                  String key =
                      "field[${widget.dataFieldGroup.id.toString()}][$index]";
                  widget.formMap[key] = value;
                  index++;
                }
                log(widget.formMap.toString() + "\n");
              },
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: MultiSelectDialogField(
              buttonText: Text("Select " + widget.dataFieldGroup.alias),
              title: Text(widget.dataFieldGroup.alias),
              buttonIcon: Icon(
                Icons.arrow_drop_down_outlined,
                color: Colors.black,
              ),
              validator: widget.dataFieldGroup.required == true
                  ? (value) {
                      if (value == null) {
                        return 'Please select an option';
                      }
                    }
                  : null,
              initialValue: selectedValuesList,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5)),
              itemsTextStyle: Theme.of(context).textTheme.bodyText1,
              selectedItemsTextStyle: Theme.of(context).textTheme.bodyText1,
              selectedColor: Colors.blue,
              items: widget.dataFieldGroup.listfieldsview
                  .map((item) => MultiSelectItem(item.id, item.label))
                  .toList(),
              listType: MultiSelectListType.LIST,
              onConfirm: (values) {
                setState(() {
                  selectedValuesList = values;
                  log(selectedValuesList.toString());
                });
                log(values.toString());
                // Stocker les valeurs sélectionnées dans widget.formMap avec des clés sans indices
                List<String> keysToRemove = widget.formMap.keys
                    .where((key) => key.startsWith(
                        "field[${widget.dataFieldGroup.id.toString()}]"))
                    .toList();

                for (var key in keysToRemove) {
                  widget.formMap.remove(key);
                }
                int index = 0;
                for (var value in values) {
                  String key =
                      "field[${widget.dataFieldGroup.id.toString()}][$index]";
                  widget.formMap[key] = value;
                  index++;
                }
                log(widget.formMap.toString() + "\n");
              },
            ),
          );
        }

      case "select":

        // Si le type de champ est "select", utilisez la liste des éléments de menu déroulant chargée depuis l'API

        if (widget.dataFieldGroup.listfieldsview.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.dataFieldGroup.alias}",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: 350,
                  child: DropdownButtonFormField<String>(
                    hint: Container(
                      width: 200,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Text(
                          "Select " + widget.dataFieldGroup.alias,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                    menuMaxHeight: 300,
                    value: _selectedValue,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.grey),
                      hintStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.5)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.5)),
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 2),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedValue = value; // Mettre à jour la sélection
                        _selectedItem = value!;
                        final fieldId = widget.dataFieldGroup.id.toString();
                        if (value == null) {
                          // Supprimer la valeur de la map si la sélection est vide
                          widget.formMap.remove("field[$fieldId]");
                        } else {
                          // Mettre à jour la valeur dans la map
                          widget.formMap["field[$fieldId]"] = value;
                        }
                        // Afficher la map dans les logs
                        log(widget.formMap.toString());
                      });
                    },
                    items: _dropdownItems.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['id'],
                        child: Container(
                          width: 300,
                          padding: EdgeInsets.only(left: 3),
                          child: Container(
                            width: 500,
                            child: Text(
                              item['label'],
                              style: TextStyle(
                                fontSize: 14,
                                overflow: TextOverflow.fade,
                              ),
                              softWrap: false,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    validator: widget.dataFieldGroup.required == true
                        ? (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner une option';
                            }
                            return null;
                          }
                        : null,
                  ),
                ),
                SizedBox(height: 10),
                if (_selectedItem != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedValue = null; // Désélection de l'item
                            _selectedItem = null;
                            final fieldId = widget.dataFieldGroup.id.toString();
                            widget.formMap.remove("field[$fieldId]");
                          });
                        },
                        child: Text(
                          'Deselect',
                          style: TextStyle(
                            color: Colors.red, // Couleur du texte
                            fontSize: 16, // Taille de police
                            fontWeight: FontWeight.bold, // Gras
                            // Autres styles que vous souhaitez appliquer
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.dataFieldGroup.alias}",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField<String>(
                  hint: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      "Select " + widget.dataFieldGroup.alias,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.black,
                  ),
                  menuMaxHeight: 300,
                  value: _selectedValue,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.grey),
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.5)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.5)),
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedValue = value; // Mettre à jour la sélection
                      _selectedItem = value;
                      log(_selectedValue.toString());
                      final fieldId = widget.dataFieldGroup.id.toString();
                      if (value == null) {
                        // Supprimer la valeur de la map si la sélection est vide
                        widget.formMap.remove("field[$fieldId]");
                      } else {
                        // Mettre à jour la valeur dans la map
                        widget.formMap["field[$fieldId]"] = value;
                        log(widget.formMap.toString());
                      }
                      // Afficher la map dans les logs
                      log(widget.formMap.toString());
                    });
                  },
                  items: widget.dataFieldGroup.listfieldsview
                      .map<DropdownMenuItem<String>>((item) {
                    return DropdownMenuItem<String>(
                      value: item.id.toString(),
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Text(
                          item.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }).toList(),
                  validator: widget.dataFieldGroup.required == true
                      ? (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner une option';
                          }
                          return null;
                        }
                      : null,
                ),
                if (_selectedItem != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedValue = null; // Désélection de l'item
                            _selectedItem = null;
                            final fieldId = widget.dataFieldGroup.id.toString();
                            widget.formMap.remove("field[$fieldId]");
                          });
                        },
                        child: Text(
                          'Deselect',
                          style: TextStyle(
                            color: Colors.red, // Couleur du texte
                            fontSize: 16, // Taille de police
                            fontWeight: FontWeight.bold, // Gras
                            // Autres styles que vous souhaitez appliquer
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }

      case "number":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            controller: _textEditingController,
            keyboardType: TextInputType.number,
            decoration: DecorationTextFormField(),
            onChanged: (value) {
              widget.formMap["field[${widget.dataFieldGroup.id.toString()}]"] =
                  value;
            },
          ),
        );

      case 'text':
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _textEditingController,
            keyboardType: TextInputType.text,
            decoration: DecorationTextFormField(),
            onChanged: (value) {
              // Cette partie peut être retirée car les mises à jour sont gérées par le contrôleur
              // widget.formMap["field[${widget.dataFieldGroup.id.toString()}]"] = value;
              // log(widget.formMap.toString());
            },
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champ est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
          ),
        );
      case 'radio':
        if (widget.dataFieldGroup.listfieldsview.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.dataFieldGroup.alias}",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                FormField(
                  builder: (state) {
                    return Column(
                      children: [
                        Column(
                          children: List.generate(
                            widget.dataFieldGroup.listfieldsview.length,
                            (index) {
                              final field =
                                  widget.dataFieldGroup.listfieldsview[index];
                              return RadioListTile<String>(
                                // Cast _selectedRadio to String before assigning
                                groupValue: _selectedRadio?.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedItem = value.toString();
                                    _selectedRadio =
                                        value!; // Ensure value is not null
                                    log(value);
                                    state.didChange(value);
                                    widget.formMap[
                                            "field[${widget.dataFieldGroup.id.toString()}]"] =
                                        value;
                                    log(widget.formMap.toString());
                                  });
                                },
                                title: Text(field.label),
                                // Cast field.id to String before assigning
                                value: field.id.toString(),
                              );
                            },
                          ),
                        ),
                        Text(
                          state.errorText ?? "",
                          style: TextStyle(
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                      ],
                    );
                  },
                  validator: widget.dataFieldGroup.required == true
                      ? (value) {
                          if (_selectedRadio == null) {
                            return 'Please select an option';
                          }
                          return null; // Valid radio button selection
                        }
                      : null,
                ),
                if (_selectedItem != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedRadio = null; // Désélection de l'item
                            _selectedItem = null;
                            final fieldId = widget.dataFieldGroup.id.toString();
                            widget.formMap.remove("field[$fieldId]");
                          });
                        },
                        child: Text(
                          'Deselect',
                          style: TextStyle(
                            color: Colors.red, // Couleur du texte
                            fontSize: 16, // Taille de police
                            fontWeight: FontWeight.bold, // Gras
                            // Autres styles que vous souhaitez appliquer
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.dataFieldGroup.alias}",
                style: Theme.of(context).textTheme.bodyText1,
              ),
              FormField(
                  validator: widget.dataFieldGroup.required == true
                      ? (value) {
                          if (_selectedRadioModule == null) {
                            return 'Please select an option';
                          }
                          return null; // Valid radio button selection
                        }
                      : null,
                  builder: (state) {
                    return Column(
                      children: [
                        Column(
                          children: List.generate(
                            radioModule.length,
                            (index) {
                              radioModule[index];
                              return RadioListTile(
                                groupValue:
                                    _selectedRadioModule, // Update groupValue here
                                onChanged: (value) {
                                  setState(() {
                                    _selectedItem = value.toString();
                                    _selectedRadioModule =
                                        radioModule[index]['id'];
                                    state.didChange(value);
                                  });
                                  print(
                                      'Selected radio: $_selectedRadioModule');
                                  widget.formMap[
                                          "field[${widget.dataFieldGroup.id.toString()}]"] =
                                      value;
                                  log(widget.formMap.toString());
                                },
                                title: Text(radioModule[index]['label']),
                                value: radioModule[index]['id'],
                              );
                            },
                          ),
                        ),
                        Text(
                          state.errorText ?? "",
                          style: TextStyle(
                            color: Theme.of(context).errorColor,
                          ),
                        )
                      ],
                    );
                  }),
              if (_selectedItem != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedRadioModule = null; // Désélection de l'item
                          _selectedItem = null;
                          final fieldId = widget.dataFieldGroup.id.toString();
                          widget.formMap.remove("field[$fieldId]");
                        });
                      },
                      child: Text(
                        'Deselect',
                        style: TextStyle(
                          color: Colors.red, // Couleur du texte
                          fontSize: 16, // Taille de police
                          fontWeight: FontWeight.bold, // Gras
                          // Autres styles que vous souhaitez appliquer
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          );
        }

      case 'checkbox':
        if (widget.dataFieldGroup.listfieldsview.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.dataFieldGroup.alias}",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                FormField(
                  builder: (state) {
                    return Column(
                      children: [
                        Column(
                          children: List.generate(
                            widget.dataFieldGroup.listfieldsview.length,
                            (index) {
                              return CheckboxListTile(
                                title: Text(widget.dataFieldGroup
                                    .listfieldsview[index].label),
                                value: _valuesChecked[index] ?? false,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedItem = value.toString();
                                    _valuesChecked[index] = value;
                                    state.didChange(value);
                                    // Mettre à jour la map lorsque la case à cocher est cochée ou décochée
                                    if (value!) {
                                      widget.formMap[
                                              "field[${widget.dataFieldGroup.id.toString()}][$index]"] =
                                          widget.dataFieldGroup
                                              .listfieldsview[index].id;
                                    } else {
                                      // Supprimer la valeur de la map si la case à cocher est décochée
                                      widget.formMap.remove(
                                          "field[${widget.dataFieldGroup.id.toString()}][$index]");
                                    }
                                    log(widget.formMap.toString());
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        Text(
                          state.errorText ?? "",
                          style: TextStyle(
                            color: Theme.of(context).errorColor,
                          ),
                        ),
                      ],
                    );
                  },
                  validator: widget.dataFieldGroup.required == true
                      ? (value) {
                          if (!_valuesChecked.contains(true)) {
                            return 'Vous devez sélectionner au moins un terme';
                          } else {
                            return null;
                          }
                        }
                      : null,
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.dataFieldGroup.alias}",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                FormField(
                  validator: widget.dataFieldGroup.required == true
                      ? (value) {
                          if (!_valuesCheckedModule.contains(true)) {
                            return 'Vous devez sélectionner au moins un terme';
                          } else {
                            return null;
                          }
                        }
                      : null,
                  builder: (field) {
                    return Column(
                      children: [
                        Column(
                          children: List.generate(
                            checkboxModule.length,
                            (index) {
                              return CheckboxListTile(
                                onChanged: (value) {
                                  setState(() {
                                    _valuesCheckedModule[index] = value;
                                    field.didChange(value);
                                    // Mettre à jour la map lorsque la case à cocher est cochée ou décochée
                                    if (value!) {
                                      widget.formMap[
                                              "field[${widget.dataFieldGroup.id.toString()}][$index]"] =
                                          checkboxModule[index]['id'];
                                    } else {
                                      // Supprimer la valeur de la map si la case à cocher est décochée
                                      widget.formMap.remove(
                                          "field[${widget.dataFieldGroup.id.toString()}][$index]");
                                    }
                                    log(widget.formMap.toString());
                                  });
                                },
                                title:
                                    Text("${checkboxModule[index]['label']}"),
                                value: _valuesCheckedModule[index],
                              );
                            },
                          ),
                        ),
                        Text(
                          field.errorText ?? "",
                          style: TextStyle(
                            color: Theme.of(context).errorColor,
                          ),
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        }

      case 'textarea':
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champs est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
            controller: _textEditingController,
            decoration: DecorationTextFormField(),
            keyboardType: TextInputType.multiline,
            maxLines: null,
          ),
        );
      case "ip address":
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            controller: _textEditingController,
            keyboardType: TextInputType.text,
            decoration: DecorationTextFormField(),
            onChanged: (value) {
              // Cette partie peut être retirée car les mises à jour sont gérées par le contrôleur
              // widget.formMap["field[${widget.dataFieldGroup.id.toString()}]"] = value;
              // log(widget.formMap.toString());
            },
            validator: widget.dataFieldGroup.required == true
                ? (value) {
                    if (value!.isEmpty) {
                      return 'Ce champ est obligatoire';
                    } else {
                      return null;
                    }
                  }
                : null,
          ),
        );

      default:
        return Text(
            'Unknown Field Type == ${widget.dataFieldGroup.field_type}');
    }
  }

  InputDecoration DecorationTextFormField() {
    return InputDecoration(
      errorStyle: TextStyle(color: Colors.red),
      constraints: BoxConstraints(),
      labelStyle: TextStyle(color: Colors.grey),
      hintStyle: TextStyle(color: Colors.grey),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.5),
      ),
      contentPadding: EdgeInsets.all(10),
      filled: true,
      fillColor: const Color.fromARGB(255, 233, 242, 247).withOpacity(0.1),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey), // Couleur du bord
      ),
      labelText: widget.dataFieldGroup.alias,
    );
  }
}
