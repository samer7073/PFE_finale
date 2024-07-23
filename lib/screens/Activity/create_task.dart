// ignore_for_file: prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/providers/langue_provider.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/screens/Activity/home_view.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/owner_select.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/select_followers.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/select_guests.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_type.dart';
import 'package:flutter_application_stage_project/services/Activities/api_create_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_families.dart';
import 'package:flutter_application_stage_project/services/Activities/api_guests.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_stage.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_users.dart';
import 'package:flutter_application_stage_project/services/Activities/api_save_files.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/shared/config.dart';
import '../homeNavigate_page.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  int? selectedTaskTypeId;
  bool isTaskTypeValid = true;
  int? selectedStageId = 20;
  bool isStageValid = true;
  int? selectedModuleId;
  String? selectedRelatedModuleId;
  bool reminderBeforeEnd = false;
  bool isLoading = false;
  final ValueNotifier<bool> _canCreateTask = ValueNotifier<bool>(false);

  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _reminderDurationController =
      TextEditingController();
  final TextEditingController _relatedModuleSearchController =
      TextEditingController();

  late ThemeProvider themeProvider;
  late LangueProvider langueProvider;
  bool isStartDateValid = true;
  bool isEndDateValid = true;
  bool isOwnerValid = true;
  bool isStartTimeValid = true;
  bool isEndTimeValid = true;
  bool isRelatedModuleValid = true;

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> followers = [];
  Map<String, dynamic>? selectedOwner;
  List<dynamic> stages = [];
  List<dynamic> guests = [];
  List<dynamic> selectedGuests = [];
  String selectedReminderDuration = '5';
  String selectedTimeUnit = 'minutes';
  List<dynamic> selectedFollowers = [];
  List<dynamic> modules = [];
  List<dynamic> relatedModules = [];
  List<Map<String, dynamic>> uploadedFiles = [];
  List<dynamic> filteredModules = [];
  List<dynamic> filteredRelatedModules = [];

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));

  String? selectedPriority;
  bool sendEmailToExternalMembers = false;
  bool isRange = false;
  bool showRelatedModulesList = false;
  late Future<String> imageUrlFuture;

  @override
  void initState() {
    super.initState();
    imageUrlFuture = Config.getApiUrl("urlImage");

    _startTimeController.text = DateFormat('HH:mm').format(_startTime);
    _endTimeController.text = DateFormat('HH:mm').format(_endTime);
    _reminderDurationController.text = selectedReminderDuration;
    _taskNameController.addListener(_validateForm);

    // Set default date to today's date
    _startDateController.text = DateFormat('d/M/y').format(DateTime.now());
    _endDateController.text = DateFormat('d/M/y').format(DateTime.now());

    fetchUsersFromApi();
    fetchStagesFromApi();
    fetchGuestsFromApi();
    fetchModulesFromApi();
  }

  void _validateForm() {
    final bool isTaskTypeValid = selectedTaskTypeId != null;
    final bool isOwnerValid = selectedOwner != null;
    final bool isTaskNameValid = _taskNameController.text.isNotEmpty;

    _canCreateTask.value = isTaskTypeValid && isOwnerValid && isTaskNameValid;
  }

  Future<void> fetchUsersFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedUsers = await fetchUsers();
      setState(() {
        users = List<Map<String, dynamic>>.from(fetchedUsers);
        followers = List<Map<String, dynamic>>.from(fetchedUsers);
      });
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchStagesFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedStages = await fetchStages();
      setState(() {
        stages = fetchedStages;
      });
    } catch (e) {
      print('Failed to load stages: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchGuestsFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedGuests = await fetchGuests();
      setState(() {
        guests = fetchedGuests;
      });
    } catch (e) {
      print('Failed to load guests: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchModulesFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedModules = await fetchFamilies();
      setState(() {
        modules = fetchedModules;
      });
    } catch (e) {
      print('Failed to load modules: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRelatedModulesFromApi(int familyId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedRelatedModules = await fetchRelatedModules(familyId);
      setState(() {
        relatedModules = fetchedRelatedModules;
        filteredRelatedModules = fetchedRelatedModules;
      });
    } catch (e) {
      print('Failed to load related modules: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _selectOwner(BuildContext context) async {
    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return OwnerSelectionSheet(users: users);
      },
    );

    if (selected != null) {
      setState(() {
        selectedOwner = selected;
        _validateForm();
      });
    }
  }

  void _selectTime(BuildContext context, bool isStartTime) async {
    DateTime initialTime = isStartTime ? _startTime : _endTime;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isStartTime ? 'Select Start Time' : 'Select End Time'),
          content: Container(
            height: 100,
            width: 100,
            child: CupertinoDatePicker(
              initialDateTime: initialTime,
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              onDateTimeChanged: (DateTime newTime) {
                setState(() {
                  if (isStartTime) {
                    _startTime = newTime;
                    _startTimeController.text =
                        DateFormat('HH:mm').format(newTime);
                    isStartTimeValid = true;
                    if (!isRange && _startTime.isAfter(_endTime)) {
                      _endTime = _startTime.add(const Duration(hours: 1));
                      _endTimeController.text =
                          DateFormat('HH:mm').format(_endTime);
                    }
                  } else {
                    _endTime = newTime;
                    _endTimeController.text =
                        DateFormat('HH:mm').format(newTime);
                    isEndTimeValid = true;
                    if (!isRange && _endTime.isBefore(_startTime)) {
                      _startTime = _endTime.subtract(const Duration(hours: 1));
                      _startTimeController.text =
                          DateFormat('HH:mm').format(_startTime);
                    }
                  }
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Set Time'),
            ),
          ],
        );
      },
    );
  }

  void _selectGuests(BuildContext context) async {
    final selected = await showModalBottomSheet<List<dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return GuestsSelectionSheet(
          guests: guests,
          selectedGuests: selectedGuests,
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedGuests = selected;
      });
    }
  }

  void _selectFollowers(BuildContext context) async {
    final selected = await showModalBottomSheet<List<dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return FollowersSelectionSheet(
          followers: followers,
          selectedFollowers: selectedFollowers,
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedFollowers = selected;
      });
    }
  }

  List<File> fileList = [];
  final Map<String, dynamic> formMap = {};
  late List<int>? files = [];

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
        formMap["upload[$count]"] =
            MultipartFile.fromBytes(FileBytes, filename: fileName);
        log("${formMap.toString()}");
        count++;
      }
      // Appelez la méthode saveFiles après avoir préparé le formMap
      List<int>? ids = await SaveFiles.saveFiles(formMap);
      log("ids " + ids.toString());
      setState(() {
        files = ids;
      });
      if (ids != null) {
        print("Files uploaded successfully with IDs: $ids");
      } else {
        print("Failed to upload files");
      }
    }
  }

  Widget _buildFileList() {
    /*
    return Column(
      children: uploadedFiles.map((file) {
        return ListTile(
          title: Text(file['name']),
          subtitle: Text('${file['size']} bytes'),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                uploadedFiles.remove(file);
              });
            },
          ),
        );
      }).toList(),
    );
    */
    return Container(
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
                final file = fileList[index].path.split('/').last;
                return ListTile(
                  title: Text('${file}'),
                  trailing: IconButton(
                    onPressed: () {
                      // Supprimer l'élément de la liste fileList
                      setState(() {
                        fileList.removeAt(index);
                        formMap.remove("upload[${index}]");
                        log(formMap.toString());
                      });
                    },
                    icon: Icon(Icons.delete_outline),
                    tooltip: 'Supprimer',
                  ),
                );
              },
            ),
    );
  }

  void _createTask() async {
    setState(() {
      isTaskTypeValid = selectedTaskTypeId != null;
      isOwnerValid = selectedOwner != null;
    });

    if (_formKey.currentState!.validate() && isTaskTypeValid && isOwnerValid) {
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to create this task?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (!confirm) return;

      final formattedStartDate = DateFormat('dd-MM-yyyy')
          .format(DateFormat('d/M/y').parse(_startDateController.text));
      final formattedEndDate = DateFormat('dd-MM-yyyy')
          .format(DateFormat('d/M/y').parse(_endDateController.text));

      final taskData = {
        'label': _taskNameController.text,
        'tasks_type_id': selectedTaskTypeId,
        'start_date': formattedStartDate,
        'end_date': formattedEndDate,
        'start_time': _startTimeController.text,
        'end_time': _endTimeController.text,
        'owner_id': selectedOwner!['id'],
        'stage_id': selectedStageId,
        'guests': selectedGuests.map((guest) => guest['id']).toList(),
        'followers':
            selectedFollowers.map((follower) => follower['id']).toList(),
        'family_id': selectedModuleId,
        'element_id': selectedRelatedModuleId,
        'description': _descriptionController.text,
        'notes': _noteController.text,
        'reminder_before_end': reminderBeforeEnd,
        'upload': files,
        'priority': selectedPriority,
        'send_email': sendEmailToExternalMembers,
        'Reminder': '$selectedReminderDuration $selectedTimeUnit',
      };
      log(taskData.toString());

      try {
        final newTask = await createTask(taskData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully!')),
        );
        if (!mounted) return;
        /*
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
            */
        // ignore: use_build_context_synchronously
        await Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => HomeNavigate(
              id_page: 1,
            ),
          ),
          (route) => false,
        ); // Retourne la nouvelle tâche
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create task: $e')),
        );
      }
    } else {
      if (selectedOwner == null) {
        setState(() {
          isOwnerValid = false;
        });
      }
      if (selectedTaskTypeId == null) {
        setState(() {
          isTaskTypeValid = false;
        });
      }
    }
  }

  void onTaskTypeSelected(int id, String label) {
    setState(() {
      selectedTaskTypeId = id;
      _taskNameController.text = label; // Mettre à jour le champ de label
      _validateForm();
    });
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _canCreateTask.dispose();
    super.dispose();
  }

  List<DropdownMenuItem<int>> _buildDropdownMenuItems(List<dynamic> modules) {
    List<DropdownMenuItem<int>> items = [];
    for (var module in modules) {
      String moduleName = module['label'];

      items.add(DropdownMenuItem(
        enabled: false,
        child: Text(moduleName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
      ));

      List<dynamic> stages = module['stages'];
      for (var stage in stages) {
        Color stageColor =
            Color(int.parse(stage['color'].replaceFirst('#', '0xff')));
        items.add(DropdownMenuItem(
          value: stage['id'],
          child: Row(
            children: <Widget>[
              Icon(Icons.brightness_1, color: stageColor, size: 12),
              const SizedBox(width: 8),
              Expanded(child: Text(stage['label'])),
            ],
          ),
        ));
      }
    }
    return items;
  }

  Widget customDatePickerBuilder(BuildContext context, Widget? child) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.blue, // Couleur de fond de l'en-tête

        colorScheme: ColorScheme.light(
          primary: Colors.blue, // Couleur de fond de l'en-tête
          onPrimary: Colors.white, // Couleur du texte de l'en-tête
          surface: Colors.white, // Couleur de fond du calendrier
          onSurface: Colors.black, // Couleur du texte
        ),
        dialogBackgroundColor:
            Colors.white, // Couleur de fond de la boîte de dialogue
      ),
      child: child!,
    );
  }

  void _handleStartDateSelection() async {
    if (isRange) {
      DateTimeRange? pickedDateRange = await showDateRangePicker(
        builder: customDatePickerBuilder,
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        initialDateRange: DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 1)),
        ),
      );

      if (pickedDateRange != null) {
        setState(() {
          _startDateController.text =
              DateFormat('d/M/y').format(pickedDateRange.start);
          log("////" + _startDateController.text);
          _endDateController.text =
              DateFormat('d/M/y').format(pickedDateRange.end);
          log("////" + _endDateController.text);
          isStartDateValid = true;
          isEndDateValid = true;
        });
      }
    } else {
      DateTime? pickedDate = await showDatePicker(
        builder: customDatePickerBuilder,
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (pickedDate != null) {
        setState(() {
          _startDateController.text = DateFormat('d/M/y').format(pickedDate);
          _endDateController.text = DateFormat('d/M/y').format(pickedDate);
          isStartDateValid = true;
          isEndDateValid = true;
        });
      }
    }
  }

  void _validateTimes() {
    if (!isRange) {
      DateTime startTime = DateFormat('HH:mm').parse(_startTimeController.text);
      DateTime endTime = DateFormat('HH:mm').parse(_endTimeController.text);

      if (startTime.isAfter(endTime)) {
        setState(() {
          isStartTimeValid = false;
          isEndTimeValid = false;
        });
      } else {
        setState(() {
          isStartTimeValid = true;
          isEndTimeValid = true;
        });
      }
    }
  }

  List<DropdownMenuItem<String>> _buildPriorityDropdownMenuItems() {
    return [
      const DropdownMenuItem<String>(
        value: 'urgent',
        child: Text('Urgent'),
      ),
      const DropdownMenuItem<String>(
        value: 'high',
        child: Text('High'),
      ),
      const DropdownMenuItem<String>(
        value: 'medium',
        child: Text('Medium'),
      ),
      const DropdownMenuItem<String>(
        value: 'low',
        child: Text('Low'),
      ),
    ];
  }

  void _filterRelatedModules(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredRelatedModules = relatedModules;
        showRelatedModulesList = false;
      });
    } else {
      setState(() {
        filteredRelatedModules = relatedModules
            .where((module) =>
                module['label'].toLowerCase().contains(query.toLowerCase()))
            .toList();
        showRelatedModulesList = true;
      });
    }
  }

  void _clearModuleSelection() {
    setState(() {
      selectedModuleId = null;
      selectedRelatedModuleId = null;
      relatedModules = [];
      filteredRelatedModules = [];
      _relatedModuleSearchController.clear();
      showRelatedModulesList = false;
    });
  }

  void _clearRelatedModuleSelection() {
    setState(() {
      selectedRelatedModuleId = null;
      _relatedModuleSearchController.clear();
      showRelatedModulesList = false;
    });
  }

  Widget _buildAvatar(Map<String, dynamic> user) {
    log("-------------------------------------------" + user.toString());
    String avatarUrl = user['avatar'] ?? '';
    String initials = user['label'].split(' ').map((name) => name[0]).join();

    return avatarUrl.isNotEmpty
        ? FutureBuilder<String>(
            future: imageUrlFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 15,
                  child: CircularProgressIndicator(),
                );
              }

              String baseUrl = snapshot.data ?? "";
              return CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 15,
                child: ClipOval(
                  child: Image.network(
                    "$baseUrl$avatarUrl",
                    fit: BoxFit.cover,
                    width: 30,
                    height: 30,
                    errorBuilder: (context, error, stackTrace) {
                      return CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 15,
                        child: Text(
                          initials,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          )
        : CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);
    langueProvider = Provider.of<LangueProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).createActivity,
            style: TextStyle(color: Colors.blue, fontSize: 25),
          ),
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.blue,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                text: AppLocalizations.of(context).activity,
              ),
              Tab(text: AppLocalizations.of(context).details),
            ],
          ),
          actions: [
            /*
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ValueListenableBuilder<bool>(
                valueListenable: _canCreateTask,
                builder: (context, canCreate, child) {
                  return ElevatedButton(
                    onPressed: canCreate ? _createTask : null,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        canCreate ? Colors.blue : Colors.grey,
                      ),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            */
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: _canCreateTask,
                  builder: (context, canCreate, child) {
                    return ElevatedButton(
                      onPressed: canCreate ? _createTask : null,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.grey;
                            }
                            return Colors.blue; // Default color
                          },
                        ),
                        overlayColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Colors.blueAccent
                                  .withOpacity(0.1); // Hover color
                            }
                            return Colors.transparent; // Default overlay color
                          },
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                        ),
                      ),
                      child: const Text(
                        "Enregistrer",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      Text(AppLocalizations.of(context).activityTypeRequired,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blueGrey)),
                      const SizedBox(height: 18.0),
                      TaskTypeSelector(
                        initialSelectedId: selectedTaskTypeId,
                        onSelected: onTaskTypeSelected,
                      ),
                      if (!isTaskTypeValid)
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            AppLocalizations.of(context)
                                .pleaseSelectActivityType,
                            style: TextStyle(color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context).labelRequired,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        height: 70,
                        child: TextFormField(
                          controller: _taskNameController,
                          decoration: InputDecoration(
                            hintText:
                                AppLocalizations.of(context).enterActivityLabel,
                            hintStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.blueGrey),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.blueGrey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.blueGrey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppLocalizations.of(context)
                                  .pleaseEnterLabel;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        AppLocalizations.of(context).ownerRequired,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 18.0),
                      InputDecorator(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).selectOwner,
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                        ),
                        child: Row(
                          children: [
                            if (selectedOwner != null)
                              _buildAvatar(selectedOwner!),
                            const SizedBox(width: 8.0),
                            if (selectedOwner != null)
                              Text(
                                selectedOwner!['label'],
                                style: const TextStyle(
                                    fontSize: 16.0, color: Colors.blueGrey),
                              ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                onTap: () => _selectOwner(context),
                              ),
                            ),
                            if (selectedOwner != null)
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    selectedOwner = null;
                                    _validateForm();
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      if (!isOwnerValid)
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            AppLocalizations.of(context).pleaseSelectOwner,
                            style: TextStyle(color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context).selectDateType,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Radio(
                            value: false,
                            groupValue: isRange,
                            onChanged: (bool? value) {
                              setState(() {
                                isRange = value!;
                              });
                            },
                          ),
                          Text(
                            AppLocalizations.of(context).singleDay,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueGrey),
                          ),
                          const SizedBox(width: 25.0),
                          Radio(
                            value: true,
                            groupValue: isRange,
                            onChanged: (bool? value) {
                              setState(() {
                                isRange = value!;
                              });
                            },
                          ),
                          Text(
                            AppLocalizations.of(context).rangeOfDays,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueGrey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).startDate,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: _startDateController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)
                                        .selectStartDate,
                                    hintStyle: const TextStyle(
                                        fontSize: 15, color: Colors.blueGrey),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                  ),
                                  readOnly: true,
                                  onTap: _handleStartDateSelection,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .pleaseSelectStartDate;
                                    }
                                    return null;
                                  },
                                ),
                                if (!isStartDateValid)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .startDateAfterEndDate,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12.0),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).endDate,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: _endDateController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)
                                        .selectEndDate,
                                    hintStyle: const TextStyle(
                                        fontSize: 15, color: Colors.blueGrey),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                  ),
                                  readOnly: true,
                                  onTap: _handleStartDateSelection,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .pleaseSelectEndDate;
                                    }
                                    return null;
                                  },
                                ),
                                if (!isEndDateValid)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .endDateBeforeStartDate,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12.0),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context).correspondingStage,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 16.0),
                      InputDecorator(
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context).selectActivityStage,
                          hintStyle: const TextStyle(
                              fontSize: 15, color: Colors.blueGrey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Container(
                          height: 20,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedStageId,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down),
                              onChanged: (int? newValue) {
                                setState(() {
                                  selectedStageId = newValue;
                                });
                              },
                              items: _buildDropdownMenuItems(stages),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).startTime,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: _startTimeController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)
                                        .selectStartTime,
                                    hintStyle: const TextStyle(
                                        fontSize: 15, color: Colors.blueGrey),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                  ),
                                  readOnly: true,
                                  onTap: () => _selectTime(context, true),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .pleaseSelectStartTime;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _validateTimes();
                                  },
                                ),
                                if (!isStartTimeValid)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .startTimeAfterEndTime,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12.0),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 18.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context).endTime,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: _endTimeController,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)
                                        .selectEndTime,
                                    hintStyle: const TextStyle(
                                        fontSize: 15, color: Colors.blueGrey),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 12.0),
                                  ),
                                  readOnly: true,
                                  onTap: () => _selectTime(context, false),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppLocalizations.of(context)
                                          .pleaseSelectEndTime;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _validateTimes();
                                  },
                                ),
                                if (!isEndTimeValid)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .endTimeBeforeStartTime,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12.0),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).guests,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueGrey),
                          ),
                          TextButton.icon(
                            onPressed: () => _selectGuests(context),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.blueGrey,
                            ),
                            label: Text(
                              AppLocalizations.of(context).add,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueGrey),
                            ),
                          ),
                        ],
                      ),
                      // Affichage des guests
                      if (selectedGuests.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 40, // Ajuster la hauteur si nécessaire
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedGuests.length,
                              itemBuilder: (context, index) {
                                final guest = selectedGuests[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Stack(
                                    children: [
                                      _buildAvatar(guest),
                                      Positioned(
                                        top: -18,
                                        right: -18,
                                        child: IconButton(
                                          icon:
                                              const Icon(Icons.close, size: 16),
                                          onPressed: () {
                                            setState(() {
                                              selectedGuests.remove(guest);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      if (selectedGuests.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CheckboxListTile(
                            activeColor: Colors.blueGrey,
                            title: Text(
                              AppLocalizations.of(context)
                                  .sendEmailToExternalMembers,
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                            value: sendEmailToExternalMembers,
                            onChanged: (bool? value) {
                              setState(() {
                                sendEmailToExternalMembers = value ?? false;
                              });
                            },
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).followers,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueGrey),
                          ),
                          TextButton.icon(
                            onPressed: () => _selectFollowers(context),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.blueGrey,
                            ),
                            label: Text(
                              AppLocalizations.of(context).add,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueGrey),
                            ),
                          ),
                        ],
                      ),
                      if (selectedFollowers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 40, // Ajuster la hauteur si nécessaire
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: selectedFollowers.length,
                              itemBuilder: (context, index) {
                                final follower = selectedFollowers[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  child: Stack(
                                    children: [
                                      _buildAvatar(follower),
                                      Positioned(
                                        top: -18,
                                        right: -18,
                                        child: IconButton(
                                          icon:
                                              const Icon(Icons.close, size: 16),
                                          onPressed: () {
                                            setState(() {
                                              selectedFollowers
                                                  .remove(follower);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context).reminderBefore,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: TextField(
                              controller: _reminderDurationController,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).duration,
                                hintStyle: const TextStyle(
                                    fontSize: 15, color: Colors.blueGrey),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.blueGrey),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.blueGrey),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  selectedReminderDuration = value;
                                });
                              },
                              style: const TextStyle(color: Colors.blueGrey),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              style: const TextStyle(color: Colors.blueGrey),
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).timeUnit,
                                hintStyle: const TextStyle(
                                    fontSize: 15, color: Colors.blueGrey),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.blueGrey),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.blueGrey),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                              ),
                              value: selectedTimeUnit,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedTimeUnit = newValue!;
                                });
                              },
                              items: <String>['minutes', 'hours', 'days']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      CheckboxListTile(
                        title: Text(
                          AppLocalizations.of(context).reminderBeforeDueDate,
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 15),
                        ),
                        value: reminderBeforeEnd,
                        onChanged: (bool? value) {
                          setState(() {
                            reminderBeforeEnd = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.blueGrey,
                      ),
                      /*
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _canCreateTask,
                          builder: (context, canCreate, child) {
                            return ElevatedButton(
                                onPressed: canCreate ? _createTask : null,
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                    canCreate ? Colors.blue : Colors.grey,
                                  ),
                                ),
                                child: Text(
                                  "Enrgistrer",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ));
                          },
                        ),
                      ),
                      */
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      Text(
                        AppLocalizations.of(context).selectModule,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      DropdownButtonFormField<int>(
                        value: selectedModuleId,
                        items: modules.map((module) {
                          return DropdownMenuItem<int>(
                            value: module['id'],
                            child: Text(module['label']),
                          );
                        }).toList(),
                        onChanged: (int? newValue) {
                          setState(() {
                            selectedModuleId = newValue;
                            fetchRelatedModulesFromApi(selectedModuleId!);
                          });
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).selectModule,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      if (selectedModuleId != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _clearModuleSelection,
                            child: Text(
                              AppLocalizations.of(context).clear,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      Text(
                        "Deselect",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      TextField(
                        controller: _relatedModuleSearchController,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context).searchRelatedModule,
                          hintStyle: const TextStyle(
                              fontSize: 15, color: Colors.blueGrey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onChanged: (value) {
                          _filterRelatedModules(value);
                        },
                        onTap: () {
                          setState(() {
                            showRelatedModulesList = true;
                          });
                        },
                      ),
                      if (showRelatedModulesList)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredRelatedModules.length,
                            itemBuilder: (context, index) {
                              final relatedModule =
                                  filteredRelatedModules[index];
                              return ListTile(
                                title: Text(relatedModule['label']),
                                onTap: () {
                                  setState(() {
                                    selectedRelatedModuleId =
                                        relatedModule['id'];
                                    _relatedModuleSearchController.text =
                                        relatedModule['label'];
                                    showRelatedModulesList = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      if (selectedRelatedModuleId != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _clearRelatedModuleSelection,
                            child: Text(
                              "Deselect",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      if (!isRelatedModuleValid)
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            AppLocalizations.of(context)
                                .pleaseSelectRelatedModule,
                            style: TextStyle(color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context).selectPriority,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      InputDecorator(
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).selectPriority,
                          hintStyle: const TextStyle(
                              fontSize: 15, color: Colors.blueGrey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.blueGrey),
                            value: selectedPriority,
                            isExpanded: false, // Set isExpanded to false
                            icon: const Icon(Icons.arrow_drop_down),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPriority = newValue;
                              });
                            },
                            items: _buildPriorityDropdownMenuItems(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context).description,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)
                              .enterActivityDescription,
                          hintStyle: const TextStyle(
                              fontSize: 15, color: Colors.blueGrey),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          suffixIcon: const Icon(Icons.description,
                              color: Colors.blueGrey),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context).note,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context).enterActivityNote,
                          hintStyle: const TextStyle(
                              fontSize: 15, color: Colors.blueGrey),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          suffixIcon: const Icon(Icons.note_add_rounded,
                              color: Colors.blueGrey),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context).uploadFiles,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blueGrey),
                        ),
                        onPressed: selectFiles,
                        child: Text(
                          AppLocalizations.of(context).upload,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      _buildFileList(),
                      const SizedBox(height: 18.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
