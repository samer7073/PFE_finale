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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Write here!',
              labelStyle: const TextStyle(color: Colors.grey),
              hintText: 'Search for owners',
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: const Color.fromARGB(255, 240, 209, 246)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: const Color.fromARGB(255, 240, 209, 246)),
                borderRadius: BorderRadius.circular(8.0),
              ),
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
                leading: CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 240, 209, 246),
                  child: Text(_getInitials(user['label'])),
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
                  const Color.fromARGB(255, 240, 209, 246)),
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
