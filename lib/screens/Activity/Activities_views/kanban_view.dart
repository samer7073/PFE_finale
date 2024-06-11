import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/pipeline.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/create_task.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/card.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_pipeline.dart';
import 'package:flutter_application_stage_project/services/Activities/api_kanban_view.dart';
import 'package:intl/intl.dart';

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
  Map<int, List<Task>> tasksByStage = {};
  bool isLoading = true;

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    pipelines = getPipelines("task");
    _pageController = PageController();
    pipelines.then((pipelineList) {
      if (pipelineList.isNotEmpty) {
        _initializeDefaultPipelineAndStage(pipelineList.first);
      }
    });
  }

  Future<void> _initializeDefaultPipelineAndStage(Pipeline pipeline) async {
    setState(() {
      selectedPipeline = pipeline;
      selectedStageId = null; // Clear the stage selection initially
      stages = pipeline.stages;
      isLoading = true;
    });

    if (stages.isNotEmpty) {
      setState(() {
        selectedStageId = _getDefaultStageIdForPipeline(pipeline);
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && stages.isNotEmpty) {
          _pageController.jumpToPage(0);
        }
      });

      await _loadTasksInParallel(pipeline.id.toString(), stages);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadTasksInParallel(
      String pipelineId, List<Stage> stages) async {
    List<Future<List<Task>>> futures = stages.map((stage) {
      return getTasksForKanban(pipelineId, stage.id);
    }).toList();

    List<List<Task>> tasksList = await Future.wait(futures);

    for (int i = 0; i < stages.length; i++) {
      tasksByStage[stages[i].id] = tasksList[i];
      _sortTasksByDate(tasksByStage[stages[i].id]!);
    }
  }

  void _sortTasksByDate(List<Task> tasks) {
    tasks.sort((a, b) {
      DateTime dateA = DateFormat('dd-MM-yyyy').parse(a.startDate);
      DateTime dateB = DateFormat('dd-MM-yyyy').parse(b.startDate);
      return dateB.compareTo(dateA); // Change to descending order
    });
  }

  int? _getDefaultStageIdForPipeline(Pipeline pipeline) {
    if (pipeline.label == 'Activity') {
      return pipeline.stages
          .firstWhere(
            (stage) => stage.label == 'To Do',
            orElse: () => pipeline.stages.first,
          )
          .id;
    } else if (pipeline.label == 'Sphere') {
      return pipeline.stages
          .firstWhere(
            (stage) => stage.label == 'Planifier',
            orElse: () => pipeline.stages.first,
          )
          .id;
    } else {
      return pipeline.stages.isNotEmpty ? pipeline.stages.first.id : null;
    }
  }

  void _clearTasks() {
    setState(() {
      selectedStageId = null;
    });
  }

  void moveTaskToStage(int newStageId, Task task) {
    setState(() {
      tasksByStage[task.stageId]?.remove(task);
      task.stageId = newStageId;
      task.stageLabel =
          stages.firstWhere((stage) => stage.id == newStageId).label;
      tasksByStage[newStageId]?.add(task);
      _sortTasksByDate(tasksByStage[newStageId]!);
    });
  }

  void refreshTasks() {
    // Refresh tasks in all stages
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 20),
            FutureBuilder<List<Pipeline>>(
              future: pipelines,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButton<Pipeline>(
                    style: const TextStyle(color: Colors.grey),
                    hint: const Text('Select Pipeline'),
                    value: selectedPipeline,
                    onChanged: (Pipeline? newValue) {
                      if (newValue != null) {
                        _clearTasks();
                        _initializeDefaultPipelineAndStage(newValue);
                        setState(() {
                          _pageController = PageController(initialPage: 0);
                        });
                      }
                    },
                    items: snapshot.data!.map((Pipeline pipeline) {
                      return DropdownMenuItem<Pipeline>(
                        value: pipeline,
                        child: Text(pipeline.label),
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                // Replace the CircularProgressIndicator with your desired widget
                return const Text("Loading...");
              },
            ),
            const SizedBox(height: 18),
            if (selectedPipeline != null && stages.isNotEmpty)
              PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var stage in stages)
                          InkWell(
                            splashColor: Colors.white,
                            overlayColor:
                                MaterialStateProperty.all(Colors.white),
                            onTap: () {
                              setState(() {
                                selectedStageId = stage.id;
                                int pageIndex = stages.indexOf(stage);
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (_pageController.hasClients) {
                                    _pageController.jumpToPage(pageIndex);
                                  }
                                });
                              });
                            },
                            child: Container(
                              height: 50,
                              width: 150,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: selectedStageId == stage.id
                                    ? const Color.fromARGB(255, 127, 177, 189)
                                    : const Color.fromARGB(255, 242, 242, 242),
                              ),
                              child: Center(
                                child: Text(
                                  stage.label,
                                  style: const TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: selectedStageId == null
                        ? const Center(child: Text('Please select a stage'))
                        : PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                selectedStageId = stages[index].id;
                              });
                            },
                            itemCount: stages.length,
                            itemBuilder: (context, index) {
                              return KanbanStage(
                                key: ValueKey(stages[index].id),
                                pipelineId: selectedPipeline!.id.toString(),
                                stage: stages[index],
                                tasks: tasksByStage[stages[index].id] ?? [],
                                onStageChanged: moveTaskToStage,
                              );
                            },
                          ),
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}

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
