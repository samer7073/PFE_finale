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

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        uploadedFiles.addAll(result.files.map((file) {
          return {
            'name': file.name,
            'size': file.size,
            'path': file.path,
          };
        }));
      });
    }
  }

  Widget _buildFileList() {
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
          'upload': uploadedFiles.map((file) => 0).toList(),
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
      _taskNameController.text = label; // Update label field
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

  List<DropdownMenuItem<String>> _buildPriorityDropdownMenuItems() {
    return [
      const DropdownMenuItem<String>(
        value: 'low',
        child: Text('Low'),
      ),
      const DropdownMenuItem<String>(
        value: 'medium',
        child: Text('Medium'),
      ),
      const DropdownMenuItem<String>(
        value: 'high',
        child: Text('High'),
      ),
      const DropdownMenuItem<String>(
        value: 'urgent',
        child: Text('Urgent'),
      ),
    ];
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

  DropdownButtonFormField<String> _buildRelatedModuleDropdown() {
    return DropdownButtonFormField<String>(
      value: relatedModules
              .any((module) => module['id'] == selectedRelatedModuleId)
          ? selectedRelatedModuleId
          : null,
      items: _buildRelatedModuleDropdownMenuItems(),
      onChanged: (String? newValue) {
        setState(() {
          selectedRelatedModuleId = newValue;
        });
      },
      decoration: InputDecoration(
        hintText: 'Select Related Module',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color.fromARGB(255, 242, 201, 249)),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _clearRelatedModuleSelection() {
    setState(() {
      selectedRelatedModuleId = null;
    });
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

  Widget _buildAvatar(String? avatar, String label) {
    if (avatar != null && avatar.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(
          'https://spherebackdev.cmk.biz:4543/storage/uploads/$avatar',
        ),
        radius: 20,
      );
    } else {
      return Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.purple,
        ),
        child: Center(
          child: Text(
            label.split(' ').map((name) => name[0]).join(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
          title: const Text(
            'Update Activity',
            style: TextStyle(color: Colors.purple, fontSize: 25),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Update Activity',
            style: TextStyle(color: Colors.purple, fontSize: 25),
          ),
          bottom: const TabBar(
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple,
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
                      MaterialStateProperty.all<Color>(Colors.purple),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
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
                              color: Colors.grey)),
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
                            color: Colors.grey),
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
                                color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 242, 201, 249)),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 242, 201, 249)),
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
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 18.0),
                      InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Select owner',
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
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
                                style: const TextStyle(fontSize: 16.0),
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
                            color: Colors.grey),
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
                                color: Color.fromARGB(255, 142, 142, 142)),
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
                                color: Color.fromARGB(255, 142, 142, 142)),
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
                                      color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: _startDateController,
                                  decoration: InputDecoration(
                                    hintText: 'Select start date',
                                    hintStyle: const TextStyle(fontSize: 15),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 242, 201, 249)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 242, 201, 249)),
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
                                      color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: _endDateController,
                                  decoration: InputDecoration(
                                    hintText: 'Select end date',
                                    hintStyle: const TextStyle(fontSize: 15),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 242, 201, 249)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 242, 201, 249)),
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
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 16.0),
                      InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Select Activity Stage',
                          hintStyle:
                              const TextStyle(fontSize: 15, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
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
                                      color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: _startTimeController,
                                  decoration: InputDecoration(
                                    hintText: 'Select start time',
                                    hintStyle: const TextStyle(fontSize: 15),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 242, 201, 249)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 242, 201, 249)),
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
                                      color: Colors.grey),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: _endTimeController,
                                  decoration: InputDecoration(
                                    hintText: 'Select end time',
                                    hintStyle: const TextStyle(fontSize: 15),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 242, 201, 249)),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Color.fromARGB(
                                              255, 242, 201, 249)),
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
                                color: Colors.grey),
                          ),
                          TextButton.icon(
                            onPressed: () => _selectGuests(context),
                            icon: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 242, 201, 249),
                            ),
                            label: const Text(
                              'Add',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 242, 201, 249)),
                            ),
                          ),
                        ],
                      ),
                      if (selectedGuests.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 8.0,
                            children: selectedGuests.map((guest) {
                              return Chip(
                                label: Text(
                                  guest['label'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.purple,
                                  child: Text(
                                    guest['label']
                                        .split(' ')
                                        .map((name) => name[0])
                                        .join(),
                                  ),
                                ),
                                onDeleted: () {
                                  setState(() {
                                    selectedGuests.remove(guest);
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                deleteIconColor: Colors.purple,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.purple, width: 2.0),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      if (selectedGuests.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CheckboxListTile(
                            activeColor: Colors.purple,
                            title: const Text(
                              'Send email to external members selected',
                              style: TextStyle(color: Colors.grey),
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
                                color: Colors.grey),
                          ),
                          TextButton.icon(
                            onPressed: () => _selectFollowers(context),
                            icon: const Icon(
                              Icons.add,
                              color: Color.fromARGB(255, 242, 201, 249),
                            ),
                            label: const Text(
                              'Add',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 242, 201, 249)),
                            ),
                          ),
                        ],
                      ),
                      if (selectedFollowers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 8.0,
                            children: selectedFollowers.map((follower) {
                              return Chip(
                                label: Text(follower['label'],
                                    style: const TextStyle(color: Colors.grey)),
                                avatar: CircleAvatar(
                                  backgroundColor: Colors.purple,
                                  child: Text(
                                    follower['label']
                                        .split(' ')
                                        .map((name) => name[0])
                                        .join(),
                                  ),
                                ),
                                onDeleted: () {
                                  setState(() {
                                    selectedFollowers.remove(follower);
                                  });
                                },
                                deleteIconColor: Colors.purple,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Colors.purple, width: 2.0),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 18.0),
                      const Text(
                        'Reminder before',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
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
                                hintStyle: const TextStyle(fontSize: 15),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color:
                                          Color.fromARGB(255, 242, 201, 249)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color:
                                          Color.fromARGB(255, 242, 201, 249)),
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
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 2,
                            child: DropdownButtonFormField<String>(
                              style: const TextStyle(color: Colors.grey),
                              decoration: InputDecoration(
                                hintText: 'Time Unit',
                                hintStyle: const TextStyle(fontSize: 15),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color:
                                          Color.fromARGB(255, 242, 201, 249)),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color:
                                          Color.fromARGB(255, 242, 201, 249)),
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
                          style: TextStyle(
                              color: Color.fromARGB(255, 118, 118, 118),
                              fontSize: 15),
                        ),
                        value: reminderBeforeEnd,
                        onChanged: (bool? value) {
                          setState(() {
                            reminderBeforeEnd = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: const Color.fromARGB(255, 242, 201, 249),
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
                            color: Colors.grey),
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
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
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
                      const SizedBox(height: 16.0),
                      const SizedBox(height: 16.0),
                      const Text(
                        'Select Related Module',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      _buildRelatedModuleDropdown(),
                      if (selectedRelatedModuleId != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _clearRelatedModuleSelection,
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.red),
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
                      const SizedBox(height: 18.0),
                      const Text(
                        'Select Priority',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      InputDecorator(
                        decoration: InputDecoration(
                          hintText: 'Select Priority',
                          hintStyle: const TextStyle(
                              fontSize: 15,
                              color: Color.fromARGB(255, 242, 201, 249)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.grey),
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
                      const Text(
                        'Description',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Enter Activity description',
                          hintStyle: const TextStyle(fontSize: 15),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          suffixIcon: const Icon(Icons.description,
                              color: Color.fromARGB(255, 242, 201, 249)),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 18.0),
                      const Text(
                        'Note',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      TextFormField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          hintText: 'Enter Activity note',
                          hintStyle: const TextStyle(fontSize: 15),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          suffixIcon: const Icon(Icons.note_add_rounded,
                              color: Color.fromARGB(255, 242, 201, 249)),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 18.0),
                      const Text(
                        'Upload Files ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 243, 218, 247)),
                        ),
                        onPressed: _pickFiles,
                        child: const Text(
                          'Upload',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      _buildFileList(),
                      const SizedBox(height: 18.0),
                      const Text(
                        'Location',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.grey),
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: 'Enter Activity location',
                          hintStyle: const TextStyle(fontSize: 15),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                                color: Color.fromARGB(255, 242, 201, 249)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                        ),
                        maxLines: 1,
                      ),
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
