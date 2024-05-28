import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/Activity_models/task.dart';
import 'package:flutter_application_stage_project/models/Activity_models/pipeline.dart';
import 'package:flutter_application_stage_project/screens/Activity/task_detail.dart';
import 'package:flutter_application_stage_project/services/Activities/api_delete_task.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_pipeline.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_stage.dart';
import 'package:flutter_application_stage_project/services/Activities/api_get_tasks.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class ListViewPage extends StatefulWidget {
  const ListViewPage({Key? key}) : super(key: key);

  @override
  _ListViewPageState createState() => _ListViewPageState();
}

class _ListViewPageState extends State<ListViewPage> {
  late List<Task> _tasks = [];
  List<Task> _selectedTasks = [];
  late TextEditingController _searchController;
  String _selectedFilter = 'All';
  bool isLoading = false;

  List<Pipeline> _pipelines = [];
  List<dynamic> _stages = [];
  List<String> _priorities = [];
  List<int> _stagesIds = [];
  int? _pipelineId;
  List<int> _roles = [];

  bool _deleteMode = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    await Future.wait([_fetchTasks(), _fetchPipelines(), _fetchStages()]);
  }

  Future<void> _fetchPipelines() async {
    try {
      final pipelines = await getPipelines(
          'task'); // Adjust 'task' to your moduleSystem if necessary
      if (!mounted) return;
      setState(() {
        _pipelines = pipelines;
      });
    } catch (e) {
      _showErrorSnackbar('Failed to load pipelines: $e');
    }
  }

  Future<void> _fetchStages() async {
    try {
      final pipelines = await fetchStages();
      if (!mounted) return;
      setState(() {
        _stages = pipelines.expand((pipeline) => pipeline['stages']).toList();
      });
    } catch (e) {
      _showErrorSnackbar('Failed to load stages: $e');
    }
  }

  Future<void> _fetchTasks({
    String? search,
    int? pipelineId,
    List<int>? stagesIds,
    List<String>? priorities,
    bool? export,
    List<int>? roles,
  }) async {
    setState(() {
      isLoading = true;
    });
    try {
      final result = await getTasks(
        search: search,
        pipelineId: pipelineId,
        stagesIds: stagesIds,
        priorities: priorities,
        export: export,
        roles: roles,
      );
      if (!mounted) return;
      setState(() {
        _tasks = result['data'] != null
            ? List<Task>.from(
                result['data'].map((taskData) => Task.fromJson(taskData)))
            : [];
      });
    } catch (e) {
      _showErrorSnackbar('Failed to load tasks: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  void _filterSearch(String searchText) {
    if (searchText.isEmpty) {
      _fetchTasks();
    } else {
      _fetchTasks(search: searchText);
    }
  }

  void _applyFilter(String filterType, String filterValue) {
    switch (filterType) {
      case 'By Priorities':
        _priorities = [filterValue];
        break;
      case 'By Stages':
        _stagesIds = [
          _stages.firstWhere((stage) => stage['label'] == filterValue)['id']
        ];
        break;
      case 'By Pipelines':
        _pipelineId = _pipelines
            .firstWhere((pipeline) => pipeline.label == filterValue)
            .id;
        break;
      default:
        _fetchTasks();
        return;
    }
    _fetchTasks(
      priorities: _priorities,
      stagesIds: _stagesIds,
      pipelineId: _pipelineId,
    );
  }

  IconData _getPriorityIcon(String? priority) {
    switch (priority) {
      case 'low':
        return Icons.flag_rounded;
      case 'medium':
        return Icons.flag_rounded;
      case 'high':
        return Icons.flag_rounded;
      case 'urgent':
        return Icons.flag_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.yellow;
      case 'high':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTaskTypeIcon(int? tasksTypeId) {
    switch (tasksTypeId) {
      case 1:
        return Icons.calendar_today;
      case 2:
        return Icons.mail_outline;
      case 3:
        return Icons.videocam;
      case 11:
        return Icons.build;
      case 4:
        return Icons.phone;
      case 12:
        return Icons.account_balance;

      default:
        return Icons.alternate_email;
    }
  }

  String _getInitials(String name) {
    return name.isNotEmpty
        ? name.split(' ').map((word) => word[0]).take(2).join().toUpperCase()
        : '';
  }

  void _showTaskDetails(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    );
  }

  void _deleteSelectedTasks() async {
    if (_selectedTasks.isEmpty) {
      _showErrorSnackbar('No tasks selected for deletion');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirmation",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.purple),
          ),
          content: const Text(
            "Are you sure you want to delete?",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color.fromARGB(255, 116, 115, 115)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.purple)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                List<String> taskIdsToDelete =
                    _selectedTasks.map((task) => task.id).toList();
                bool success = await deleteTasks(taskIdsToDelete);
                if (success) {
                  setState(() {
                    _tasks.removeWhere((task) => _selectedTasks.contains(task));
                    _selectedTasks.clear();
                    _deleteMode = false;
                  });
                  scaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(content: Text('Tasks deleted successfully')),
                  );
                } else {
                  _showErrorSnackbar('Failed to delete tasks');
                }
              },
              child:
                  const Text("Delete", style: TextStyle(color: Colors.purple)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshTasks() async {
    await _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              if (_deleteMode) _buildDeleteButton(),
              _buildTaskList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color.fromARGB(255, 229, 231, 247),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (value) {
                      _filterSearch(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterMenu(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterMenu() {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'All',
            child:
                Text('All', style: TextStyle(fontSize: 15, color: Colors.grey)),
          ),
          const PopupMenuItem<String>(
            value: 'By Pipelines',
            child: Text('By Pipelines',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
          ),
          const PopupMenuItem<String>(
            value: 'By Stages',
            child: Text('By Stages',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
          ),
          const PopupMenuItem<String>(
            value: 'By Priorities',
            child: Text('By Priorities',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
          ),
        ];
      },
      onSelected: (String value) {
        if (value == 'All') {
          setState(() {
            _selectedFilter = 'All';
            _fetchTasks();
          });
        } else {
          setState(() {
            _selectedFilter = value;
          });
          _showFilterDialog(value);
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13.0),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            Text(_selectedFilter,
                style: const TextStyle(fontSize: 15, color: Colors.grey)),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
      offset: const Offset(0, 30),
    );
  }

  void _showFilterDialog(String filterType) {
    List<String> filterOptions;
    switch (filterType) {
      case 'By Pipelines':
        filterOptions = _pipelines.map((pipeline) => pipeline.label).toList();
        break;
      case 'By Stages':
        filterOptions =
            _stages.map((stage) => stage['label'].toString()).toList();
        break;
      case 'By Priorities':
        filterOptions = ['high', 'medium', 'low', 'urgent'];
        break;
      default:
        filterOptions = [];
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(45.0),
          ),
          title: Text(
            'Filter $filterType',
            style: const TextStyle(color: Colors.purple, fontSize: 20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: filterOptions.map((option) {
              return ListTile(
                title: Center(
                  child: Text(
                    option,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 123, 123, 123),
                        fontSize: 15),
                  ),
                ),
                onTap: () {
                  _applyFilter(filterType, option);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.purple, fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeleteButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _deleteSelectedTasks,
          child: const Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshTasks,
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  Task task = _tasks[index];

                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        _deleteMode = true;
                        task.isChecked = true;
                        _selectedTasks.add(task);
                      });
                    },
                    child: ListTile(
                      leading: _deleteMode
                          ? Checkbox(
                              visualDensity: VisualDensity.compact,
                              value: task.isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  task.isChecked = value ?? false;
                                  if (task.isChecked) {
                                    _selectedTasks.add(task);
                                  } else {
                                    _selectedTasks.remove(task);
                                  }
                                });
                              },
                              activeColor: Colors.purple,
                            )
                          : null,
                      isThreeLine: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 16.0),
                      minVerticalPadding: 8.0,
                      title: Row(
                        children: [
                          Icon(_getTaskTypeIcon(task.tasksTypeId),
                              color: Colors.purple, size: 20),
                          const SizedBox(width: 8),
                          Text(task.label ?? ''),
                          const SizedBox(width: 8),
                          Icon(
                            _getPriorityIcon(task.priority),
                            color: _getPriorityColor(task.priority),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text('${task.startDate ?? ''}'),
                              const SizedBox(width: 5),
                              Text('- ${task.endDate ?? ''}'),
                              const SizedBox(width: 8),
                            ],
                          ),
                          Row(
                            children: [
                              Text('${task.startTime ?? ''}'),
                              const SizedBox(width: 5),
                              Text('- ${task.endTime ?? ''}'),
                            ],
                          ),
                        ],
                      ),
                      trailing: CircleAvatar(
                        backgroundColor: Colors.purple,
                        radius: 14,
                        child: task.ownerAvatar != null &&
                                task.ownerAvatar!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  'https://spherebackdev.cmk.biz:4543/storage/uploads/${task.ownerAvatar}',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Text(
                                      _getInitials(task.ownerLabel ?? ''),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                _getInitials(task.ownerLabel ?? ''),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      onTap: () {
                        _showTaskDetails(context, task);
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
