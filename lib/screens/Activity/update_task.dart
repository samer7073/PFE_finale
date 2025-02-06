// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, avoid_unnecessary_containers, deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/providers/theme_provider.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/owner_select.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/select_followers.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/select_guests.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_type.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_families.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_stage.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_users.dart';
import 'package:flutter_application_stage_project/services/Activities/api_guests.dart';
import 'package:flutter_application_stage_project/services/Activities/api_update_task.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/shared/config.dart';
import '../../services/Activities/api_save_files.dart';

class UpdateTaskScreen extends StatefulWidget {
  final String taskId;

  UpdateTaskScreen({required this.taskId});

  @override
  _UpdateTaskScreenState createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  int? selectedTaskTypeId;
  bool isTaskTypeValid = true;
  int? selectedStageId;
  bool isStageValid = true;
  int? selectedModuleId;
  String? selectedRelatedModuleId;
  bool reminderBeforeEnd = false;
  bool isLoading = false;

  late TextEditingController _taskNameController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _descriptionController;
  late TextEditingController _noteController;
  late TextEditingController _locationController;
  late TextEditingController _reminderDurationController;
  late List<Upload> saveFiels = [];
  late ThemeProvider themeProvider;

  bool isStartDateValid = true;
  bool isEndDateValid = true;
  bool isOwnerValid = true;
  bool isStartTimeValid = true;
  bool isEndTimeValid = true;
  bool isRelatedModuleValid = true;
  bool labelTest = true;

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
  late int is_follower;
  late int can_update_task;

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));

  String? selectedPriority;
  List<String> priorities = ['high', 'medium', 'low', 'urgent'];
  bool sendEmailToExternalMembers = false;
  bool showRelatedModulesList = false;
  bool isRange = false;

  bool isTaskTypeLoading = true;

  @override
  void initState() {
    super.initState();

    _taskNameController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _startTimeController = TextEditingController();
    _endTimeController = TextEditingController();
    _descriptionController = TextEditingController();
    _noteController = TextEditingController();
    _locationController = TextEditingController();
    _reminderDurationController = TextEditingController();

    fetchUsersFromApi();
    fetchStagesFromApi();
    fetchGuestsFromApi();
    fetchModulesFromApi();
    imageUrlFuture = Config.getApiUrl("urlImage");

    fetchTaskDetails(widget.taskId);
  }

  late Future<String> imageUrlFuture;

  @override
  void dispose() {
    _taskNameController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    _locationController.dispose();
    _reminderDurationController.dispose();

    super.dispose();
  }

  Future<void> fetchTaskDetails(String taskId) async {
    try {
      final response = await getTaskDetails(taskId);
      log('API Response: $response');
      can_update_task = response['data']['can_update_task'];
      is_follower = response['data']['is_follower'];

      log("can_update_task 111111111111111111111 $can_update_task   $is_follower");

      final task = Task.fromJson(response['data']);
      print('Reminder :${task.reminder}');
      reminderBeforeEnd = task.reminderBeforeEnd!;

      _taskNameController.text = task.label;
      sendEmailToExternalMembers = task.send_email == 1 ? true : false;
      _startDateController.text = task.startDate;
      _endDateController.text = task.endDate;
      _startTimeController.text = task.startTime;
      _endTimeController.text = task.endTime;
      _descriptionController.text = task.description;
      _noteController.text = task.note;
      _locationController.text = task.location;
      if (task.uploads.isNotEmpty) {
        saveFiels = task.uploads;
        for (var upload in task.uploads) {
          files!.add(upload.id);
        }
      }

      // Extract reminder duration and unit
      final reminderParts = task.reminder.split(' ');
      if (reminderParts.length == 2) {
        selectedReminderDuration = reminderParts[0];
        selectedTimeUnit = reminderParts[1];
      }

      // Update the reminder controller
      _reminderDurationController.text = selectedReminderDuration;

      setState(() {
        selectedPriority = task.priority.isEmpty ? null : task.priority;
        if (selectedPriority != null &&
            !priorities.contains(selectedPriority)) {
          selectedPriority = null;
        }
        selectedTaskTypeId = task.tasksTypeId;
        selectedStageId = task.stageId;
        selectedModuleId = task.familyId;
        selectedRelatedModuleId = task.elementId;

        selectedOwner = {
          'id': task.ownerId,
          'label': task.ownerLabel,
          'avatar': task.ownerAvatar,
        };
        selectedGuests = task.guests; // Assign guests
        selectedFollowers = task.followers; // Assign followers
      });
      // Fetch related modules after setting the selected module ID
      if (selectedModuleId != null) {
        await fetchRelatedModulesFromApi(selectedModuleId!);
      }
      print('element id:${task.elementId}');
      print('Task initialized with ownerId: ${task.ownerId}');
      print('Initial selectedOwner: $selectedOwner');
    } catch (e) {
      print('Failed to fetch task details: $e');
    } finally {
      setState(() {
        isTaskTypeLoading = false;
      });
    }
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
        isOwnerValid = true;
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
          content: SizedBox(
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
                  } else {
                    _endTime = newTime;
                    _endTimeController.text =
                        DateFormat('HH:mm').format(newTime);
                    isEndTimeValid = true;
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
        for (var id in ids!) {
          files!.add(id);
        }
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
          ? Text("${AppLocalizations.of(context)!.nofilesselected}")
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

  void _updateTask() async {
    log("test 11111111111111");
    if (_formKey.currentState!.validate() &&
        selectedTaskTypeId != null &&
        selectedOwner != null &&
        isStartDateValid &&
        isEndDateValid &&
        isStartTimeValid &&
        isEndTimeValid) {
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmationTask),
          content:  Text(AppLocalizations.of(context)!.areyousureyouwanttoupdatethistask),
          actions: [
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.noword,
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child:  Text(
                 AppLocalizations.of(context)!.yesword ,
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );

      if (!confirm) return;

      try {
        final formattedStartDate = _startDateController.text;

        final formattedEndDate = _endDateController.text;

        final taskData = {
          'label': _taskNameController.text,
          'tasks_type_id': selectedTaskTypeId,
          'start_date': formattedStartDate,
          'end_date': formattedEndDate,
          'start_time': _startTimeController.text,
          'end_time': _endTimeController.text,
          'owner_id':
              selectedOwner != null ? selectedOwner!['id'] : widget.taskId,
          'stage_id': selectedStageId,
          'guests': selectedGuests.map((guest) => guest['id']).toList(),
          'followers':
              selectedFollowers.map((follower) => follower['id']).toList(),
          'family_id': selectedModuleId,
          'element_id': selectedRelatedModuleId,
          'description': _descriptionController.text,
          'note': _noteController.text,
          'reminder_before_end': reminderBeforeEnd,
          'upload': files,
          'priority': selectedPriority,
          'send_email': sendEmailToExternalMembers,
          'location': _locationController.text,
          'Reminder': '$selectedReminderDuration $selectedTimeUnit',
        };

        print('Task Data: $taskData');

        await updateTask(widget.taskId, taskData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Task updated successfully!',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );

/*
        Navigator.pushAndRemoveUntil<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => HomeNavigate(
              id_page: 1,
            ),
          ),
          (route) => false,
        );*/

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                'Failed to update task: $e',
                style: TextStyle(color: Colors.white),
              )),
        );
        log('Failed to update task: $e');
      }
    } else {
      log("test 22222222222222222");
      log("test selectedowner $selectedOwner");
      if (selectedOwner == null) {
        setState(() {
          isOwnerValid = false;
        });
        log("test is overvalild $isOwnerValid");
      }
      if (selectedTaskTypeId == null) {
        setState(() {
          isTaskTypeValid = false;
        });
      }
      if (selectedStageId == null) {
        setState(() {
          isStageValid = false;
        });
      }
      if (_startTimeController.text.isEmpty) {
        setState(() {
          isStartTimeValid = false;
        });
      }
      if (_endTimeController.text.isEmpty) {
        setState(() {
          isEndTimeValid = false;
        });
      }
      if (selectedModuleId != null && selectedRelatedModuleId == null) {
        setState(() {
          isRelatedModuleValid = false;
        });
      }
      if (_taskNameController.text.isEmpty) {
        setState(() {
          labelTest = false;
        });
      }
    }
  }

  void onTaskTypeSelected(int id, String label) {
    if (can_update_task == 1) {
      setState(() {
        selectedTaskTypeId = id;
        _taskNameController.text = label; // Mettre à jour le champ de label
      });
    }
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

  List<DropdownMenuItem<String>> _buildRelatedModuleDropdownMenuItems() {
    if (relatedModules.isEmpty) {
      return [
        const DropdownMenuItem<String>(
          enabled: false,
          child: Text(
            'No data',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    }
    return relatedModules
        .map((relatedModule) => DropdownMenuItem<String>(
              value: relatedModule['id'],
              child: Text(relatedModule['label']),
            ))
        .toList();
  }

  void _handleStartDateSelection() async {
    if (isRange) {
      DateTimeRange? pickedDateRange = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        initialDateRange: DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 1)),
        ),
      );

      if (pickedDateRange != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? dateFormat = prefs.getString('date_formate') ??
            'DD-MM-YYYY'; // Valeur par défaut si non définie
        String pattern = dateFormat
            .replaceAll('DD', 'dd')
            .replaceAll('YYYY', 'yyyy')
            .replaceAll('MM', 'MM');
        setState(() {
          _startDateController.text =
              DateFormat(pattern).format(pickedDateRange.start);
          _endDateController.text =
              DateFormat(pattern).format(pickedDateRange.end);
          isStartDateValid = true;
          isEndDateValid = true;
        });
      }
    } else {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? dateFormat = prefs.getString('date_formate') ??
          'DD-MM-YYYY'; // Valeur par défaut si non définie
      String pattern = dateFormat
          .replaceAll('DD', 'dd')
          .replaceAll('YYYY', 'yyyy')
          .replaceAll('MM', 'MM');

      if (pickedDate != null) {
        setState(() {
          _startDateController.text = DateFormat(pattern).format(pickedDate);
          _endDateController.text = DateFormat(pattern).format(pickedDate);
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

  void _clearModuleSelection() {
    setState(() {
      selectedModuleId = null;
      selectedRelatedModuleId = null;
      relatedModules = [];
    });
  }

  Future<String> _getImageUrl() async {
    return await Config.getApiUrl("urlImage");
  }

  Widget _buildAvatar(String? avatar, String ownerLabel) {
    String initial = ownerLabel.isNotEmpty ? ownerLabel[0].toUpperCase() : '?';

    if (avatar == null || avatar.isEmpty || avatar.length == 1) {
      // Show the initial of the owner's name if avatar is null or empty
      return CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 15,
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      return FutureBuilder<String>(
        future: imageUrlFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 15,
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          if (snapshot.hasError) {
            return CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 15,
              child: Text(
                initial,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          String baseUrl = snapshot.data ?? "";
          return CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 15,
            child: ClipOval(
              child: Image.network(
                "$baseUrl$avatar",
                fit: BoxFit.cover,
                width: 30,
                height: 30,
                errorBuilder: (context, error, stackTrace) {
                  return CircleAvatar(
                    backgroundColor: Colors.blue,
                    radius: 15,
                    child: Text(
                      initial,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);
    if (isTaskTypeLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
           AppLocalizations.of(context)!.updateactivity,
            style: TextStyle(color: Colors.blue, fontSize: 25),
          ),
        ),
        body: const Center(
            child: CircularProgressIndicator(
          color: Colors.blue,
        )),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title:  Text(
            AppLocalizations.of(context)!.updateactivity,
            style: TextStyle(color: Colors.blue, fontSize: 25),
          ),
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                text: AppLocalizations.of(context)!.activity,
              ),
              Tab(text: AppLocalizations.of(context)!.details),
            ],
          ),
          actions: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: ElevatedButton(
                  onPressed: () {
                    log("test" + selectedOwner.toString());

                    _updateTask();
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
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
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 8.0),
                    ),
                  ),
                  child:  Text(
                    AppLocalizations.of(context)!.update,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
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
                      Text(AppLocalizations.of(context)!.activityTypeRequired,
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
                            AppLocalizations.of(context)!
                                .pleaseSelectActivityType,
                            style: TextStyle(color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context)!.labelRequired,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        child: Container(
                          decoration: boxdecoration(themeProvider),
                          child: TextFormField(
                            readOnly: can_update_task == 0,
                            controller: _taskNameController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .enterActivityLabel,
                              hintStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.blueGrey),
                              enabledBorder: InputBorder
                                  .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {}
                              return null;
                            },
                          ),
                        ),
                      ),
                      if (!labelTest)
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            AppLocalizations.of(context)!.labelRequired,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      Text(
                        AppLocalizations.of(context)!.ownerRequired,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 18.0),
                      Container(
                        decoration: boxdecoration(themeProvider),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.selectOwner,
                            enabledBorder: InputBorder
                                .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                          ),
                          child: Row(
                            children: [
                              if (selectedOwner != null)
                                _buildAvatar(selectedOwner!['avatar'],
                                    selectedOwner!['label']),
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
                                  onTap: () => can_update_task == 0
                                      ? null
                                      : _selectOwner(context),
                                ),
                              ),
                              if (selectedOwner != null && can_update_task == 1)
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      selectedOwner = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!isOwnerValid)
                        Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            AppLocalizations.of(context)!.pleaseSelectOwner,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14.0),
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      Text(
                        AppLocalizations.of(context)!.selectDateType,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        decoration: boxdecoration(themeProvider),
                        child: Row(
                          children: [
                            Radio(
                              value: false,
                              groupValue: isRange,
                              onChanged: (bool? value) {
                                setState(() {
                                  isRange = value!;
                                });
                              },
                              activeColor: Color.fromARGB(255, 52, 7, 255),
                            ),
                            Text(
                              AppLocalizations.of(context)!.singleDay,
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
                              activeColor: Color.fromARGB(255, 52, 7, 255),
                            ),
                            Text(
                              AppLocalizations.of(context)!.rangeOfDays,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.startDate,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  decoration: boxdecoration(themeProvider),
                                  child: TextFormField(
                                    controller: _startDateController,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .selectStartDate,
                                      hintStyle: const TextStyle(
                                          fontSize: 15, color: Colors.blueGrey),
                                      enabledBorder: InputBorder
                                          .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                                      focusedBorder: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                    ),
                                    readOnly: true,
                                    onTap: _handleStartDateSelection,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .pleaseSelectStartDate;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                if (!isStartDateValid)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
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
                                  AppLocalizations.of(context)!.endDate,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  decoration: boxdecoration(themeProvider),
                                  child: TextFormField(
                                    controller: _endDateController,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .selectEndDate,
                                      hintStyle: const TextStyle(
                                          fontSize: 15, color: Colors.blueGrey),
                                      enabledBorder: InputBorder
                                          .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                                      focusedBorder: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                    ),
                                    readOnly: true,
                                    onTap: _handleStartDateSelection,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .pleaseSelectEndDate;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                if (!isEndDateValid)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
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
                        AppLocalizations.of(context)!.correspondingStage,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        decoration: boxdecoration(themeProvider),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .selectActivityStage,
                              hintStyle: const TextStyle(
                                  fontSize: 15, color: Colors.blueGrey),
                              enabledBorder: InputBorder
                                  .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                              focusedBorder: InputBorder.none,
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
                                  AppLocalizations.of(context)!.startTime,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  decoration: boxdecoration(themeProvider),
                                  child: TextFormField(
                                    controller: _startTimeController,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .selectStartTime,
                                      hintStyle: const TextStyle(
                                          fontSize: 15, color: Colors.blueGrey),
                                      enabledBorder: InputBorder
                                          .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                                      focusedBorder: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                    ),
                                    readOnly: true,
                                    onTap: () => _selectTime(context, true),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .pleaseSelectStartTime;
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _validateTimes();
                                    },
                                  ),
                                ),
                                if (!isStartTimeValid)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
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
                                  AppLocalizations.of(context)!.endTime,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueGrey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  decoration: boxdecoration(themeProvider),
                                  child: TextFormField(
                                    controller: _endTimeController,
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!
                                          .selectEndTime,
                                      hintStyle: const TextStyle(
                                          fontSize: 15, color: Colors.blueGrey),
                                      enabledBorder: InputBorder
                                          .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                                      focusedBorder: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 12.0),
                                    ),
                                    readOnly: true,
                                    onTap: () => _selectTime(context, false),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return AppLocalizations.of(context)!
                                            .pleaseSelectEndTime;
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      _validateTimes();
                                    },
                                  ),
                                ),
                                if (!isEndTimeValid)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      AppLocalizations.of(context)!
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.guests,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueGrey),
                          ),
                          Container(
                            decoration: boxdecoration(themeProvider),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _selectGuests(context),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.blueGrey,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.add,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (selectedGuests.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 40,
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
                                      _buildAvatar(
                                          guest['avatar'], guest['label']),
                                      Positioned(
                                        top: -18,
                                        right: -18,
                                        child: IconButton(
                                          icon: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              child: const Icon(Icons.close,
                                                  size: 16)),
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
                              AppLocalizations.of(context)!
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.followers,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueGrey),
                          ),
                          Container(
                            decoration: boxdecoration(themeProvider),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _selectFollowers(context),
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.blueGrey,
                                  ),
                                  label: Text(
                                    AppLocalizations.of(context)!.add,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blueGrey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (selectedFollowers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: SizedBox(
                            height: 40,
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
                                      _buildAvatar(follower['avatar'],
                                          follower['label']),
                                      Positioned(
                                        top: -18,
                                        right: -18,
                                        child: IconButton(
                                          icon: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              child: const Icon(Icons.close,
                                                  size: 16)),
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
                       AppLocalizations.of(context)!.reminderBefore,
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
                            child: Container(
                              decoration: boxdecoration(themeProvider),
                              child: TextField(
                                controller: _reminderDurationController,
                                decoration: InputDecoration(
                                  hintText:   AppLocalizations.of(context)!.duration,
                                  hintStyle: const TextStyle(
                                      fontSize: 15, color: Colors.blueGrey),
                                  enabledBorder: InputBorder
                                      .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                                  focusedBorder: InputBorder.none,
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
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 2,
                            child: Container(
                              decoration: boxdecoration(themeProvider),
                              child: DropdownButtonFormField<String>(
                                style: const TextStyle(color: Colors.blueGrey),
                                decoration: InputDecoration(
                                  hintText:   AppLocalizations.of(context)!.timeUnit,
                                  hintStyle: const TextStyle(
                                      fontSize: 15, color: Colors.blueGrey),
                                  enabledBorder: InputBorder
                                      .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                                  focusedBorder: InputBorder.none,
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      CheckboxListTile(
                        title:  Text(
                          AppLocalizations.of(context)!.reminderBeforeDueDate,
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                       Text(
                         AppLocalizations.of(context)!.selectModule,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Container(
                        decoration: boxdecoration(themeProvider),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                          child: DropdownButtonFormField<int>(
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            hint: Center(
                              // Propriété spécifique de DropdownButtonFormField
                              child: Text(
                                AppLocalizations.of(context)!.selectModule,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (selectedModuleId != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _clearModuleSelection,
                            child: const Text(
                              'Deselect',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 18,
                      ),
                       Text(
                      AppLocalizations.of(context)!.relatedElement,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Container(
                        decoration: boxdecoration(themeProvider),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .searchRelatedModule,
                              hintStyle: const TextStyle(
                                  fontSize: 15, color: Colors.blueGrey),
                              enabledBorder: InputBorder
                                  .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                              focusedBorder: InputBorder.none,
                            ),
                            child: Container(
                              height: 20,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedRelatedModuleId,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedRelatedModuleId = newValue;
                                      isRelatedModuleValid = true;
                                    });
                                  },
                                  items: _buildRelatedModuleDropdownMenuItems(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isRelatedModuleValid)
                         Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                           AppLocalizations.of(context)!
                                .pleaseSelectRelatedModule,
                            style: TextStyle(color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                       Text(
                        AppLocalizations.of(context)!.selectPriority,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Container(
                        decoration: boxdecoration(themeProvider),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              hintText:   AppLocalizations.of(context)!.selectPriority,
                              hintStyle: const TextStyle(
                                  fontSize: 15, color: Colors.blueGrey),
                              enabledBorder: InputBorder
                                  .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                              focusedBorder: InputBorder.none,
                            ),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.blueGrey,
                              ),
                              value: selectedPriority,
                              isExpanded: false,
                              icon: const Icon(Icons.arrow_drop_down),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedPriority = newValue;
                                });
                              },
                              items: priorities.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18.0),
                       Text(
                        AppLocalizations.of(context)!.description,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Container(
                        decoration: boxdecoration(themeProvider),
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText:  AppLocalizations.of(context)!
                                .enterActivityDescription,
                            hintStyle: const TextStyle(
                                fontSize: 15, color: Colors.blueGrey),
                            enabledBorder: InputBorder
                                .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            suffixIcon: const Icon(Icons.description,
                                color: Colors.blueGrey),
                          ),
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(height: 18.0),
                       Text(
                         AppLocalizations.of(context)!.note,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      Container(
                        decoration: boxdecoration(themeProvider),
                        child: TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText:  AppLocalizations.of(context)!.enterActivityNote,
                            hintStyle: const TextStyle(
                                fontSize: 15, color: Colors.blueGrey),
                            enabledBorder: InputBorder
                                .none, // Enlever la bordure lorsque le TextFormField n'est pas sélectionné
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            suffixIcon: const Icon(Icons.note_add_rounded,
                                color: Colors.blueGrey),
                          ),
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(height: 18.0),
                       Text(
                          AppLocalizations.of(context)!.uploadFiles,
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
                        child:  Text(
                          AppLocalizations.of(context)!.upload,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      _buildFileList(),
                      saveFiels == null
                          ? Text("")
                          : Container(
                              height: saveFiels == null
                                  ? 0
                                  : saveFiels!.length * 50,
                              child: ListView.builder(
                                itemCount: saveFiels!.length,
                                itemBuilder: (context, index) {
                                  final file = saveFiels![index];
                                  return ListTile(
                                    trailing: IconButton(
                                      onPressed: () {
                                        // Supprimer l'élément de la liste fileList
                                        setState(() {
                                          saveFiels!.removeAt(index);
                                          /*
                                        widget.formMap.remove(
                                            "field[${widget.dataFieldGroup.id.toString()}][${index}]");
                                            */
                                        });
                                      },
                                      icon: Icon(Icons.delete_outline),
                                      tooltip: 'Supprimer',
                                    ),
                                    title: GestureDetector(
                                      child: Text(
                                        file.fileName,
                                        style: TextStyle(
                                            color: Colors.blue.shade600),
                                      ),
                                      onTap: () {
                                        _launchInBrowser(file.fileName);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
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

  Future<void> _launchInBrowser(String file_name) async {
    Uri uri = Uri(
      scheme: 'https',
      host: 'spherebackdev.cmk.biz',
      port: 4543,
      path: '/storage/uploads/$file_name',
    );
    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $uri');
    }
  }

  BoxDecoration boxdecoration(ThemeProvider themeProvider) {
    return BoxDecoration(
        color: themeProvider.isDarkMode
                                ? const Color.fromARGB(255, 29, 28, 28)
                                : Color.fromARGB(255, 240, 241, 241),
        borderRadius: BorderRadius.circular(5));
  }
}
