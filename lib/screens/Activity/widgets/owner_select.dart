// ignore_for_file: sort_child_properties_last

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';

class OwnerSelectionSheet extends StatefulWidget {
  final List<Map<String, dynamic>> users;

  OwnerSelectionSheet({required this.users});

  @override
  _OwnerSelectionSheetState createState() => _OwnerSelectionSheetState();
}

class _OwnerSelectionSheetState extends State<OwnerSelectionSheet> {
  List<Map<String, dynamic>> filteredUsers = [];
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    filteredUsers = widget.users;
    _imageUrlFuture = _loadImageUrl();
  }

  Future<String> _loadImageUrl() async {
    try {
      final url = await Config.getApiUrl("urlImage");
      log(url + "999999999999999999999999999999999999 url owners ul");
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load image URL: $e')),
        );
      }
      return ''; // Return an empty string in case of failure
    }
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

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = widget.users
          .where((user) =>
              user['label']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildAvatar(String? avatarUrl, String baseUrl) {
    if (avatarUrl!.length == 1) {
      return CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          avatarUrl,
          style: const TextStyle(color: Colors.white),
        ),
        radius: 15,
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage("$baseUrl$avatarUrl"),
        radius: 15,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final imageUrl = snapshot.data ?? '';

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
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 58, 119, 216)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 58, 119, 216)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                ),
                onChanged: _filterUsers, // Utilisez la méthode _filterUsers ici
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
                      imageUrl,
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
      },
    );
  }
}
