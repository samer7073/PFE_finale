import 'package:flutter/material.dart';

class OwnerSelectionSheet extends StatefulWidget {
  final List<Map<String, dynamic>> users;

  OwnerSelectionSheet({required this.users});

  @override
  _OwnerSelectionSheetState createState() => _OwnerSelectionSheetState();
}

class _OwnerSelectionSheetState extends State<OwnerSelectionSheet> {
  List<Map<String, dynamic>> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = widget.users;
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = widget.users
          .where((user) =>
              user['label']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  String _getInitials(String name) {
    List<String> nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return '';
  }

  Widget _buildAvatar(String? avatarUrl, String ownerName) {
    if (avatarUrl == null || avatarUrl.isEmpty) {
      String initials = _getInitials(ownerName);
      return CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          initials,
          style: const TextStyle(color: Colors.white),
        ),
        radius: 15,
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(
            "https://spherebackdev.cmk.biz:4543/storage/uploads/$avatarUrl"),
        radius: 15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'Search for owners',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color.fromARGB(255, 58, 119, 216)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color.fromARGB(255, 58, 119, 216)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
            ),
            onChanged: _filterUsers,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return ListTile(
                leading: _buildAvatar(
                  user['avatar'],
                  user['label'],
                ),
                title: Text(user['label']),
                onTap: () {
                  Navigator.pop(context, user);
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 58, 119, 216)),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
