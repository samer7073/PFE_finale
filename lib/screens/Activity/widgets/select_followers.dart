import 'package:flutter/material.dart';

class FollowersSelectionSheet extends StatefulWidget {
  final List<dynamic> followers;
  final List<dynamic> selectedFollowers;

  const FollowersSelectionSheet({required this.followers, required this.selectedFollowers});

  @override
  _FollowersSelectionSheetState createState() => _FollowersSelectionSheetState();
}

class _FollowersSelectionSheetState extends State<FollowersSelectionSheet> {
  late List<dynamic> _selectedFollowers;
  List<dynamic> _filteredFollowers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedFollowers = List.from(widget.selectedFollowers);
    _filteredFollowers = widget.followers;
    _searchController.addListener(_filterFollowers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFollowers);
    _searchController.dispose();
    super.dispose();
  }

  void _filterFollowers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFollowers = widget.followers.where((follower) {
        final name = follower['label'].toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  String _getInitials(String name) {
    List<String> names = name.split(" ");
    String initials = "";
    int numWords = names.length > 2 ? 2 : names.length;
    for (int i = 0; i < numWords; i++) {
      initials += names[i][0];
    }
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search Followers',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredFollowers.length,
            itemBuilder: (context, index) {
              final follower = _filteredFollowers[index];
              final isSelected = _selectedFollowers.contains(follower);
              return CheckboxListTile(
                activeColor: const Color.fromARGB(255, 240, 209, 246),
                secondary: CircleAvatar(
                  
                  child: Text(
                    _getInitials(follower['label']),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.purple,
                ),
                title: Text(follower['label']),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedFollowers.add(follower);
                    } else {
                      _selectedFollowers.remove(follower);
                    }
                  });
                },
              );
            },
          ),
        ),
        ElevatedButton(
          style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 240, 209, 246)),
  ),
          onPressed: () {
            Navigator.pop(context, _selectedFollowers);
          },
          child: Text('Done', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}