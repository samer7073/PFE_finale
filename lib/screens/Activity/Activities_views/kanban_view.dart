import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/pipeline.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/screens/Activity/widgets/task_card.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_pipeline.dart';
import 'package:flutter_application_stage_project/services/Activities/api_kanban_view.dart';
import 'package:flutter_application_stage_project/services/Activities/api_update_stage_task.dart';

class KanbanBoard extends StatefulWidget {
  const KanbanBoard({super.key});

  @override
  _KanbanBoardState createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  late Future<List<Pipeline>> pipelines;
  Pipeline? selectedPipeline;
  int? selectedStageId;

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

  void _initializeDefaultPipelineAndStage(Pipeline pipeline) {
    setState(() {
      selectedPipeline = pipeline;
      final toDoStage = selectedPipeline?.stages.firstWhere(
          (stage) => stage.label == 'To Do',
          orElse: () => selectedPipeline!.stages.first);
      selectedStageId = toDoStage?.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          FutureBuilder<List<Pipeline>>(
            future: pipelines,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return DropdownButton<Pipeline>(
                  style: TextStyle(color: Colors.grey),
                  hint: const Text('Select Pipeline'),
                  value: selectedPipeline,
                  onChanged: (Pipeline? newValue) {
                    if (newValue != null) {
                      _initializeDefaultPipelineAndStage(newValue);
                      setState(() {
                        _pageController = PageController();
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
              return const CircularProgressIndicator();
            },
          ),
          SizedBox(
            height: 18,
          ),
          if (selectedPipeline != null)
            PreferredSize(
              preferredSize: const Size.fromHeight(70),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var stage in selectedPipeline!.stages)
                        InkWell(
                          splashColor: Colors.white,
                          overlayColor: MaterialStateProperty.all(Colors.white),
                          onTap: () {
                            setState(() {
                              selectedStageId = stage.id;
                              int pageIndex =
                                  selectedPipeline!.stages.indexOf(stage);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
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
                                  ? const Color.fromARGB(255, 239, 204, 246)
                                  : Color.fromARGB(255, 242, 242, 242),
                            ),
                            child: Center(
                              child: Text(
                                stage.label,
                                style: TextStyle(color: Colors.purple),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: selectedStageId == null
                ? const Center(child: Text('Please select a stage'))
                : PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        selectedStageId = selectedPipeline!.stages[index].id;
                      });
                    },
                    itemCount: selectedPipeline!.stages.length,
                    itemBuilder: (context, index) {
                      return KanbanStage(
                        pipelineId: selectedPipeline!.id.toString(),
                        stage: selectedPipeline!.stages[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class KanbanStage extends StatefulWidget {
  final String pipelineId;
  final Stage stage;

  KanbanStage({required this.pipelineId, required this.stage});

  @override
  State<KanbanStage> createState() => _KanbanStageState();
}

class _KanbanStageState extends State<KanbanStage> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    try {
      List<Task> tasks =
          await getTasksForKanban(widget.pipelineId, widget.stage.id);
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch tasks')),
      );
    }
  }

  void _removeTask(String taskId) {
    setState(() {
      _tasks.removeWhere((task) => task.id == taskId);
    });
  }

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });
  }

  void _updateTaskStage(Task task, int newStageId) async {
    bool success = await updateTaskStage(task.id, newStageId);
    if (success) {
      setState(() {
        _tasks.remove(task);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update task stage')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onAccept: (task) {
        _updateTaskStage(task, widget.stage.id);
      },
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
                    return TaskCard(
                      task: task,
                      onDelete: _removeTask,
                      onStageUpdate: (task, newStageId) =>
                          _updateTaskStage(task, newStageId),
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
