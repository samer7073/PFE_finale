import 'package:flutter/material.dart';

class FollowersSelectionSheet extends StatefulWidget {
  final List<dynamic> followers;
  final List<dynamic> selectedFollowers;

  const FollowersSelectionSheet(
      {required this.followers, required this.selectedFollowers});

  @override
  _FollowersSelectionSheetState createState() =>
      _FollowersSelectionSheetState();
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
                activeColor: Colors.blue,
                secondary: _buildAvatar(follower),
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
            backgroundColor: MaterialStateProperty.all<Color>(
                const Color.fromARGB(255, 58, 119, 216)),
          ),
          onPressed: () {
            Navigator.pop(context, _selectedFollowers);
          },
          child: Text('Done', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildAvatar(Map<String, dynamic> user) {
    String avatarUrl = user['avatar'] ?? '';
    String initials = user['label'].split(' ').map((name) => name[0]).join();

    return avatarUrl.isNotEmpty
        ? CircleAvatar(
            backgroundImage: NetworkImage(
                "https://spherebackdev.cmk.biz:4543/storage/uploads/$avatarUrl"),
          )
        : CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white),
            ),
          );
  }
}
