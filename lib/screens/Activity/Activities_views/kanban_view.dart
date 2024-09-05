// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors

import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/pipeline.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';

import 'package:flutter_application_stage_project/services/Activities/api_get_pipeline.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/shared/config.dart';
import '../../../services/Activities/api_delete_task.dart';
import '../../../services/Activities/api_get_stage.dart';
import '../../../services/Activities/api_update_priority.dart';
import '../../../services/Activities/api_update_stage_task.dart';
import '../../../services/sharedPreference.dart';
import '../task_detail.dart';
import '../update_task.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  _KanbanBoardState createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  late Future<List<Pipeline>> pipelines;
  Pipeline? selectedPipeline;
  int? selectedStageId;
  List<Stage> stages = [];
  List<dynamic> stagesPip = [];
  Map<int, List<Task>> tasksByStage = {};
  bool isLoading = true;
  late Future<String> imageUrlFuture;
  late PageController _pageController;
  late ScrollController _scrollController; // Added ScrollController
  List<Task> tasks = [];
  int _currentPage = 1; // Track current page
  bool _isLoadingMore = false; // Track if more tasks are loading
  bool _hasMoreTasks = true; // Assume there are more tasks initially

  @override
  void initState() {
    super.initState();
    fetchStagesFromApi();
    imageUrlFuture = Config.getApiUrl("urlImage");
    pipelines = getPipelines("task");

    _pageController = PageController();
    _scrollController = ScrollController()
      ..addListener(_scrollListener); // Initialize ScrollController

    pipelines.then((pipelineList) {
      if (pipelineList.isNotEmpty) {
        _initializeDefaultPipelineAndStage(pipelineList.first);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose ScrollController
    super.dispose();
  }

  int getStagePercentageById(List<Stage> stages, int id) {
    for (Stage stage in stages) {
      if (stage.id == id) {
        return stage.percent;
      }
    }
    // Si aucun stage avec l'id donné n'est trouvé, retourner -1
    return -1;
  }

  String getStageColorById(List<Stage> stages, int id) {
    for (Stage stage in stages) {
      if (stage.id == id) {
        return stage.getColor;
      }
    }
    // Si aucun stage avec l'id donné n'est trouvé, retourner -1
    return "#000000";
  }

  // La méthode qui fait l'appel API
  Future<List<Task>> getTasksForStage(int stageId, int page) async {
    final basurl = await Config.getApiUrl("taskStagesElements");
    final url = '$basurl$stageId?page=$page&limit=10';
    log('Fetching tasks from: $url');

    try {
      final token = await SharedPrefernce.getToken("token");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log('Response status: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        final List<Task> newTasks =
            (data as List).map((task) => Task.fromJson(task)).toList();
        _hasMoreTasks = newTasks.length ==
            10; // Assume a full page means more tasks to load
        return newTasks;
      } else {
        log('Failed to load tasks with status code: ${response.statusCode}');
        throw Exception('Failed to load tasks');
      }
    } catch (error) {
      log('Error fetching tasks: $error');
      throw Exception('Failed to load tasks: $error');
    }
  }

  Future<void> _initializeDefaultPipelineAndStage(Pipeline pipeline) async {
    setState(() {
      selectedPipeline = pipeline;
      selectedStageId = null; // Clear the stage selection initially
      stages = pipeline.stages;
      isLoading = true;
    });

    if (stages.isNotEmpty) {
      final defaultStageId = _getDefaultStageIdForPipeline(pipeline);
      setState(() {
        selectedStageId = defaultStageId;
        _currentPage = 1; // Reset the page to 1
        tasks = []; // Clear current tasks
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && stages.isNotEmpty) {
          _pageController.jumpToPage(0);
        }
      });

      // Charge les tâches pour le stage par défaut
      tasks = await getTasksForStage(defaultStageId!, _currentPage);

      setState(() {
        tasksByStage[defaultStageId] = tasks;

        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadTasksForStage(int stageId) async {
    setState(() {
      _currentPage = 1; // Reset the page to 1
      tasks = []; // Clear current tasks
      _isLoadingMore = false;
      _hasMoreTasks = true;
      isLoading = true;
    });

    try {
      final newTasks = await getTasksForStage(stageId, _currentPage);

      setState(() {
        tasks = newTasks;
        tasksByStage[stageId] = tasks;
        isLoading = false;
      });
    } catch (error) {
      log('Error loading tasks for selected stage: $error');
    }
  }

  void _clearTasks() {
    setState(() {
      selectedStageId = null;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreTasks) {
        _loadMoreTasks();
      }
    }
  }

  void _loadMoreTasks() async {
    if (selectedStageId == null) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage += 1; // Increment the page
    });

    try {
      final newTasks = await getTasksForStage(selectedStageId!, _currentPage);

      setState(() {
        tasks.addAll(newTasks);
        _isLoadingMore = false;
      });
    } catch (error) {
      setState(() {
        _isLoadingMore = false;
        _hasMoreTasks = false; // Stop loading more if there's an error
      });
      log('Error loading more tasks: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 20),
            FutureBuilder<List<Pipeline>>(
              future: pipelines,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    width: 200,
                    child: InputDecorator(
                      expands: false,
                      decoration: InputDecoration(
                        labelText: 'Pipeline', // Adding the label
                        border: OutlineInputBorder(), // Adding the border
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Pipeline>(
                          isExpanded: true,
                          style: const TextStyle(color: Colors.grey),
                          hint: const Text('Select Pipeline'),
                          value: selectedPipeline,
                          onChanged: (Pipeline? newValue) {
                            if (newValue != null) {
                              _clearTasks();
                              _initializeDefaultPipelineAndStage(newValue);
                              setState(() {
                                _pageController =
                                    PageController(initialPage: 0);
                              });
                            }
                          },
                          items: snapshot.data!.map((Pipeline pipeline) {
                            return DropdownMenuItem<Pipeline>(
                              value: pipeline,
                              child: Text(pipeline.label),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return const Text("Loading...");
              },
            ),
            const SizedBox(height: 18),
            if (selectedPipeline != null && stages.isNotEmpty)
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Center(
                  child: SizedBox(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var stage in stages)
                            InkWell(
                                onTap: () async {
                                  setState(() {
                                    selectedStageId = stage.id;
                                    _currentPage = 1; // Reset the page to 1

                                    _loadTasksForStage(stage
                                        .id); // Load tasks for the selected stage
                                  });
                                },
                                child: Container(
                                  height: 42,
                                  padding: EdgeInsets.symmetric(
                                    vertical: 12.0,
                                    horizontal: 15.0,
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: selectedStageId == stage.id
                                        ? Color.fromARGB(255, 34, 63, 249)
                                        : isDarkMode == true
                                            ? Colors.black
                                            : Colors.white,
                                    border: Border.all(
                                      color: selectedStageId == stage.id
                                          ? Color.fromARGB(255, 34, 63, 249)
                                          : Color.fromARGB(255, 200, 200,
                                              200), // Couleur de la bordure non sélectionnée
                                      width: 0.50,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      stage.label,
                                      style: TextStyle(
                                        color: selectedStageId == stage.id
                                            ? Colors.white
                                            : isDarkMode
                                                ? Colors.white
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 250.0),
                child: const Center(
                    child: CircularProgressIndicator(
                  color: Colors.blue,
                )),
              )
            else if (selectedStageId != null)
              tasks.length > 0
                  ? Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: tasks.length +
                            (_isLoadingMore
                                ? 1
                                : 0), // Add an extra item if loading more
                        itemBuilder: (context, taskIndex) {
                          if (taskIndex == tasks.length) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: Colors.blue,
                            ));
                          }
                          final task = tasks[taskIndex];

                          DateTime startDate = _parseDate(task.startDate);
                          DateTime endDate = _parseDate(task.endDate);
                          bool isOverdue = endDate.isBefore(DateTime.now());
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300,
                                  width:
                                      1), // Bordure grise de 1 pixel de large
                              borderRadius: BorderRadius.circular(
                                  15), // Coins arrondis (facultatif)
                            ),
                            //borderOnForeground: false,
                            //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            //color: Colors.white,
                            margin: const EdgeInsets.all(10.0),
                            //elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          _buildPriorityFlag(
                                              task.priority ?? 'None',
                                              task,
                                              isDarkMode),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            task.task_type_label,
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Color.fromARGB(
                                                    255, 59, 85, 251),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      PopupMenuButton<String>(
                                        onSelected: (String value) {
                                          _onPopupMenuSelected(value, task);
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return [
                                            const PopupMenuItem<String>(
                                              value: 'details',
                                              child: ListTile(
                                                leading:
                                                    Icon(Icons.info_outline),
                                                title: Text('Details'),
                                              ),
                                            ),
                                            if (task.can_update_task == 1)
                                              const PopupMenuItem<String>(
                                                value: 'edit',
                                                child: ListTile(
                                                  leading:
                                                      Icon(Icons.edit_outlined),
                                                  title: Text('Edit'),
                                                ),
                                              ),
                                            if (task.can_update_task == 1)
                                              const PopupMenuItem<String>(
                                                value: 'delete',
                                                child: ListTile(
                                                  leading: Icon(
                                                      Icons.delete_outline),
                                                  title: Text('Delete'),
                                                ),
                                              ),
                                          ];
                                        },
                                        icon: Icon(
                                          Icons.more_horiz_outlined,
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.label,
                                          style: TextStyle(
                                            color: isDarkMode == true
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 25,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      //_buildPriorityFlag(_task.priority ?? 'None'),
                                    ],
                                  ),
                                  const SizedBox(height: 10.0),
                                  Text(
                                    "Progress",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  // Stage Progress Indicator

                                  GestureDetector(
                                    onTap: () {
                                      if (task.is_follower == 0)
                                        _showStageDialogKanban(
                                            task.stageLabel, task.id, task);
                                    },
                                    child: _buildStageProgressIndicator(
                                        getStagePercentageById(
                                            stages, selectedStageId!),
                                        task.stageLabel,
                                        getStageColorById(
                                            stages, selectedStageId!),
                                        isDarkMode),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  // Level 2
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today,
                                              color: Colors
                                                  .blue), // Icône pour le début
                                          SizedBox(
                                              width:
                                                  4), // Espacement entre l'icône et le texte
                                          Text(
                                              " ${DateFormat('dd-MM-yyyy').format(startDate)}"),
                                          SizedBox(
                                              width:
                                                  16), // Espacement entre les deux paires
                                          Icon(Icons.event,
                                              color: Colors
                                                  .red), // Icône pour la fin
                                          SizedBox(
                                              width:
                                                  4), // Espacement entre l'icône et le texte
                                          Text(
                                            " ${DateFormat('dd-MM-yyyy').format(endDate)}",
                                            style: TextStyle(
                                              color: isOverdue
                                                  ? Colors.red
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (task.guests.isNotEmpty) ...[
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: _buildAvatars(
                                            task.guests
                                                .map((guest) => {
                                                      'avatar': guest['avatar']
                                                          as String?,
                                                      'label': guest['label']
                                                          as String
                                                    })
                                                .toList(),
                                            maxAvatars: 4,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                      if (task.followers.isNotEmpty) ...[
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: _buildAvatarsFollowers(
                                              task.followers
                                                  .map((follower) => {
                                                        'avatar':
                                                            follower['avatar']
                                                                as String?,
                                                        'label':
                                                            follower['label']
                                                                as String
                                                      })
                                                  .toList(),
                                              maxAvatars: 4),
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    ],
                                  ),

                                  // Level 4
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 250),
                      child: Center(
                        child: Text(
                          'No data to display for this stage',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageProgressIndicator(
      int stagePercent, String stageLabel, String stageColor, isDarkMode) {
    return Row(
      children: [
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            minHeight: 7,
            value: stagePercent / 100,
            color: Colors.blue,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(_parseColor(stageColor)),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Text(
          '${stagePercent}%',
          style: TextStyle(
              fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
        ),
      ],
    );
  }

  void _onPopupMenuSelected(String value, Task task) {
    switch (value) {
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateTaskScreen(taskId: task.id),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(task);
        break;
      case 'details':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(taskId: task.id),
          ),
        );
        break;
    }
  }

  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await deleteTasks(task.id);
                    setState(() {
                      tasks.remove(task);
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete task: $e',style: TextStyle(color: Colors.white),)),
                    );
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.blue),
                )),
          ],
        );
      },
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xff')));
    } catch (e) {
      return Colors.black; // Fallback color if parsing fails
    }
  }

  int? _getDefaultStageIdForPipeline(Pipeline pipeline) {
    // Customize this method to determine the default stage ID for a given pipeline
    return pipeline.stages.isNotEmpty ? pipeline.stages.first.id : null;
  }

  Widget _buildAvatarsFollowers(List<Map<String, String?>> avatarsAndLabels,
      {int maxAvatars = 3}) {
    List<Widget> avatarWidgets = [];
    for (int i = 0; i < avatarsAndLabels.length && i < maxAvatars; i++) {
      final label = avatarsAndLabels[i]['label'];
      avatarWidgets.add(Positioned(
        left: i * 20.0,
        child: Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          verticalOffset: 48,
          height: 50,
          textStyle: TextStyle(color: Colors.white),
          message: "Follower: $label",
          child: _buildAvatar(
              avatarsAndLabels[i]['avatar'], avatarsAndLabels[i]['label']!),
        ),
      ));
    }

    if (avatarsAndLabels.length > maxAvatars) {
      avatarWidgets.add(Positioned(
        left: maxAvatars * 20.0,
        child: CircleAvatar(
          radius: 15,
          backgroundColor: const Color.fromARGB(
              255, 50, 63, 69), // Set a background color if needed
          child: Text(
            '+${avatarsAndLabels.length - maxAvatars}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
    }

    return Container(
      width: (maxAvatars + 1) * 30.0, // Adjust width to ensure full display
      height: 40,
      color: Colors.transparent, // Ensure background is transparent
      child: Stack(children: avatarWidgets),
    );
  }

  Widget _buildAvatar(String? avatar, String label) {
    if (avatar!.isEmpty || avatar.length == 1) {
      String initial = avatar != null && avatar.length == 1
          ? avatar
          : (label.isNotEmpty ? label[0].toUpperCase() : '?');
      return CircleAvatar(
        radius: 15,
        backgroundColor: Colors.blueGrey, // Set a background color if needed
        child: Text(
          initial,
          style: TextStyle(color: Colors.white),
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

          String baseUrl = snapshot.data ?? "";
          return CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 15,
            child: CachedNetworkImage(
              imageUrl: "$baseUrl$avatar",
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(
                color: Colors.blue,
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        },
      );
    }
  }

  Widget _buildAvatars(List<Map<String, String?>> avatarsAndLabels,
      {int maxAvatars = 3}) {
    List<Widget> avatarWidgets = [];
    for (int i = 0; i < avatarsAndLabels.length && i < maxAvatars; i++) {
      final label = avatarsAndLabels[i]['label'];
      avatarWidgets.add(Positioned(
        left: i * 20.0,
        child: Tooltip(
          triggerMode: TooltipTriggerMode.tap,
          verticalOffset: 48,
          height: 50,
          textStyle: TextStyle(color: Colors.white),
          message: "Guest: $label",
          child: _buildAvatar(
              avatarsAndLabels[i]['avatar'], avatarsAndLabels[i]['label']!),
        ),
      ));
    }

    if (avatarsAndLabels.length > maxAvatars) {
      avatarWidgets.add(Positioned(
        left: maxAvatars * 20.0,
        child: CircleAvatar(
          radius: 15,
          backgroundColor: const Color.fromARGB(
              255, 50, 63, 69), // Set a background color if needed
          child: Text(
            '+${avatarsAndLabels.length - maxAvatars}',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ));
    }

    return Container(
      width: (maxAvatars + 1) * 30.0, // Adjust width to ensure full display
      height: 40,
      color: Colors.transparent, // Ensure background is transparent
      child: Stack(children: avatarWidgets),
    );
  }

  void _showStageDialogKanban(String? stageLabel, String id, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Text('Selected Stage '),
              Text(
                stageLabel ?? "No pipeline available",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: hexToColor(task.stageColor),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width:
                double.maxFinite, // Ensure the dialog takes up the full width
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 16),
                  if (stages.isNotEmpty) ...MenuItems(stagesPip, id, task),
                  if (stages.isEmpty)
                    Text(
                      "No stages available",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close',style: TextStyle(
                color: Colors.blue
              ),),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  List<Widget> MenuItems(List<dynamic> modules, String id, Task task) {
    List<Widget> items = [];
    for (var module in modules) {
      String moduleName = module['label'];

      items.add(Text(
        moduleName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ));

      List<dynamic> stagesd = module['stages'];
      for (var stage in stagesd) {
        Color stageColor =
            Color(int.parse(stage['color'].replaceFirst('#', '0xff')));
        items.add(GestureDetector(
          onTap: () async {
            try {
              // Attempt to update the task stage
              await updateTaskStage(id, stage['id']);
              setState(() {
                tasks.remove(task);
              });
              Navigator.of(context).pop();

              if (mounted) {
                _showUpdateDialog('Stage updated to ${stage['label']}');
              }
            } catch (e) {
              if (mounted) {
                _showUpdateDialog('Failed to update stage: $e');
              }
            }
          },
          child: Row(
            children: <Widget>[
              Icon(Icons.brightness_1, color: stageColor, size: 12),
              const SizedBox(width: 10),
              SizedBox(
                height: 50,
              ),
              Expanded(
                child: Text(stage['label']),
              ),
            ],
          ),
        ));
      }
      items.add(const SizedBox(height: 20));
    }
    return items;
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Future<void> fetchStagesFromApi() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedStages = await fetchStages();
      setState(() {
        stagesPip = fetchedStages;
        isLoading = false;
      });
    } catch (e) {
      print('Failed to load stages: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildPriorityFlag(String priority, Task task, bool isDarkMode) {
    Color flagColor;
    switch (priority.toLowerCase()) {
      case 'low':
        flagColor = Colors.grey;
        break;
      case 'medium':
        flagColor = Colors.blue;
        break;
      case 'high':
        flagColor = Colors.orange;
        break;
      case 'urgent':
        flagColor = Colors.red;
        break;
      default:
        flagColor = isDarkMode ? Colors.white : Colors.transparent;
        break;
    }
    return GestureDetector(
      onTap: () {
        if (task.can_update_task == 1) _showPriorityDialog(task);
      }, // Correctly using a lambda here
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.flag_outlined, color: Colors.black),
          Icon(Icons.flag, color: flagColor),
        ],
      ),
    );
  }

  void _showPriorityDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPriorityOption('Low', Colors.grey, task),
              _buildPriorityOption('Medium', Colors.blue, task),
              _buildPriorityOption('High', Colors.orange, task),
              _buildPriorityOption('Urgent', Colors.red, task),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Status'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPriorityOption(String priority, Color color, Task task) {
    return ListTile(
      leading: Stack(alignment: Alignment.center, children: [
        const Icon(Icons.flag_outlined, color: Colors.black),
        Icon(Icons.flag, color: color)
      ]),
      title: Text(priority),
      onTap: () async {
        Navigator.of(context).pop();
        try {
          await updateTaskPriority(task.id, priority);
          if (mounted) {
            setState(() {
              task.priority = priority;
            });
            _showUpdateDialog('Priority updated to $priority');
          }
        } catch (e) {
          if (mounted) {
            _showUpdateDialog('Failed to update priority: $e');
          }
        }
      },
    );
  }

  DateTime _parseDate(String date) {
    try {
      return DateFormat('dd-MM-yyyy').parse(date);
    } catch (e) {
      throw FormatException('Invalid date format: $date');
    }
  }
}
/*
class KanbanStage extends StatefulWidget {
  final String pipelineId;
  final Stage stage;
  final List<Task> tasks;
  final Function(int, Task) onStageChanged;

  KanbanStage({
    super.key,
    required this.pipelineId,
    required this.stage,
    required this.tasks,
    required this.onStageChanged,
  });

  @override
  State<KanbanStage> createState() => _KanbanStageState();
}

class _KanbanStageState extends State<KanbanStage> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();

    _tasks = List.from(widget.tasks); // Create a copy of the tasks list
  }

  @override
  void didUpdateWidget(covariant KanbanStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pipelineId != oldWidget.pipelineId ||
        widget.stage.id != oldWidget.stage.id ||
        widget.tasks != oldWidget.tasks) {
      setState(() {
        _tasks = List.from(widget.tasks); // Create a copy of the tasks list
      });
      _sortTasksByDate();
    }
  }

  void _sortTasksByDate() {
    _tasks.sort((a, b) {
      DateTime dateA = DateFormat('dd-MM-yyyy').parse(a.startDate);
      DateTime dateB = DateFormat('dd-MM-yyyy').parse(b.startDate);
      return dateB.compareTo(dateA); // Change to descending order
    });
  }

  void _removeTask(Task task) {
    setState(() {
      _tasks.remove(task);
    });
  }

  void _onStageChanged(int newStageId, Task task) {
    _removeTask(task);
    widget.onStageChanged(newStageId, task);
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 300,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, taskIndex) {
                    final task = _tasks[taskIndex];
                    return TaskCard1(
                      key: ValueKey(
                          task.id), // Ensure each card has a unique key
                      task: task,
                      onStageChanged: (newStageId) =>
                          _onStageChanged(newStageId, task),
                      onDelete: () => _removeTask(task),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
*/