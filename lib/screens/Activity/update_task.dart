import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
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
import 'package:url_launcher/url_launcher.dart';

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

    fetchTaskDetails(widget.taskId);
  }

  void _validateForm() {
    final bool isTaskTypeValid = selectedTaskTypeId != null;
    final bool isOwnerValid = selectedOwner != null;
    final bool isTaskNameValid = _taskNameController.text.isNotEmpty;
  }

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
      print('API Response: $response');

      final task = Task.fromJson(response['data']);
      print('Reminder :${task.reminder}');

      _taskNameController.text = task.label;
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

  void _updateTask() async {
    if (_formKey.currentState!.validate() &&
        selectedTaskTypeId != null &&
        (selectedOwner != null || widget.taskId.isNotEmpty) &&
        isStartDateValid &&
        isEndDateValid &&
        isStartTimeValid &&
        isEndTimeValid) {
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Are you sure you want to update this task?'),
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

      try {
        final formattedStartDate = DateFormat('dd-MM-yyyy').format(
          DateFormat('d-M-y').parse(_startDateController.text),
        );
        final formattedEndDate = DateFormat('dd-MM-yyyy').format(
          DateFormat('d-M-y').parse(_endDateController.text),
        );

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
          'notes': _noteController.text,
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
          const SnackBar(content: Text('Task updated successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update task: $e')),
        );
        print('Failed to update task: $e');
      }
    } else {
      if (selectedOwner == null && widget.taskId.isEmpty) {
        setState(() {
          isOwnerValid = false;
        });
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
    }
  }

  void onTaskTypeSelected(int id, String label) {
    setState(() {
      selectedTaskTypeId = id;
      _taskNameController.text = label; // Mettre à jour le champ de label
      _validateForm();
    });
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
        setState(() {
          _startDateController.text =
              DateFormat('d-M-y').format(pickedDateRange.start);
          _endDateController.text =
              DateFormat('d-M-y').format(pickedDateRange.end);
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

      if (pickedDate != null) {
        setState(() {
          _startDateController.text = DateFormat('d-M-y').format(pickedDate);
          _endDateController.text = DateFormat('d-M-y').format(pickedDate);
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

  Widget _buildAvatar(String? avatar, String ownerLabel) {
    if (avatar == null || avatar.length == 1) {
      // Show the initial of the owner's name if avatar is null or empty
      String initial =
          ownerLabel.isNotEmpty ? ownerLabel[0].toUpperCase() : '?';
      return CircleAvatar(
        backgroundColor: Colors.blue,
        radius: 15,
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 20,
        child: ClipOval(
          child: Image.network(
            "https://spherebackdev.cmk.biz:4543/storage/uploads/$avatar",
            fit: BoxFit.cover,
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 20,
                child: Text(
                  ownerLabel.isNotEmpty ? ownerLabel[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isTaskTypeLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Update Activity',
            style: TextStyle(color: Colors.blue, fontSize: 25),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Update Activity',
            style: TextStyle(color: Colors.blue, fontSize: 25),
          ),
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                text: 'Activity',
              ),
              Tab(text: 'Details'),
            ],
          ),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _updateTask,
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.blueGrey,
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
                      const Text('Activity Type *',
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
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please select an Activity type',
                            style: TextStyle(color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      const Text(
                        'Label *',
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
                            hintText: 'Enter Activity label',
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
                              return 'Please enter a label';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Owner *',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 18.0),
                      InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Select owner',
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
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please select an owner',
                            style: TextStyle(color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      const Text(
                        'Select Date Type',
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
                          const Text(
                            'Single Day',
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
                          const Text(
                            'Range of Days',
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
                                const Text(
                                  'Start Date',
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
                                    hintText: 'Select start date',
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
                                      return 'Please select a start date';
                                    }
                                    return null;
                                  },
                                ),
                                if (!isStartDateValid)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Start date cannot be after end date',
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
                                const Text(
                                  'End Date',
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
                                    hintText: 'Select end date',
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
                                      return 'Please select an end date';
                                    }
                                    return null;
                                  },
                                ),
                                if (!isEndDateValid)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'End date cannot be before start date',
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
                      const Text(
                        'Corresponding Stage',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 16.0),
                      InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Select Activity Stage',
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
                                const Text(
                                  'Start Time',
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
                                    hintText: 'Select start time',
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
                                      return 'Please select a start time';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _validateTimes();
                                  },
                                ),
                                if (!isStartTimeValid)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'Start time cannot be after end time',
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
                                const Text(
                                  'End Time',
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
                                    hintText: 'Select end time',
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
                                      return 'Please select an end time';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _validateTimes();
                                  },
                                ),
                                if (!isEndTimeValid)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'End time cannot be before start time',
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
                          const Text(
                            'Guests',
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
                            label: const Text(
                              'Add',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueGrey),
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
                            title: const Text(
                              'Send email to external members selected',
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
                          const Text(
                            'Followers',
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
                            label: const Text(
                              'Add',
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
                      const Text(
                        'Reminder before',
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
                                hintText: 'Duration',
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
                                hintText: 'Time Unit',
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
                        title: const Text(
                          'Reminder before due date',
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
                      const Text(
                        'Select Module',
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
                          hintText: 'Select Module',
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
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      const SizedBox(
                        height: 18,
                      ),
                      const Text(
                        'Select Related Module',
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
                          hintText: 'Select Related Module',
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
                      if (!isRelatedModuleValid)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Please select a related module',
                            style: TextStyle(color: Colors.red, fontSize: 12.0),
                          ),
                        ),
                      const Text(
                        'Select Priority',
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
                          hintText: 'Select Priority',
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
                      const SizedBox(height: 18.0),
                      const Text(
                        'Description',
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
                          hintText: 'Enter Activity description',
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
                      const Text(
                        'Note',
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
                          hintText: 'Enter Activity note',
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
                      const Text(
                        'Upload Files ',
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
                        child: const Text(
                          'Upload',
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
}
