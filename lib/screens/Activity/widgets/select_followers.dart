import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';

class FollowersSelectionSheet extends StatefulWidget {
  final List<dynamic> followers;
  final List<dynamic> selectedFollowers;

  const FollowersSelectionSheet({
    required this.followers,
    required this.selectedFollowers,
  });

  @override
  _FollowersSelectionSheetState createState() =>
      _FollowersSelectionSheetState();
}

class _FollowersSelectionSheetState extends State<FollowersSelectionSheet> {
  late List<dynamic> _selectedFollowers;
  List<dynamic> _filteredFollowers = [];
  final TextEditingController _searchController = TextEditingController();
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _selectedFollowers = List.from(widget.selectedFollowers);
    _filteredFollowers = widget.followers;
    _searchController.addListener(_filterFollowers);
    _imageUrlFuture = _loadImageUrl();
  }

  Future<String> _loadImageUrl() async {
    try {
      final url = await Config.getApiUrl("urlImage");
      log(url + "999999999999999999999999999999999999 url flowers ul");
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
    return FutureBuilder<String>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final imageUrl = snapshot.data ?? '';

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
                    secondary: _buildAvatar(follower, imageUrl),
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
                  const Color.fromARGB(255, 58, 119, 216),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, _selectedFollowers);
              },
              child: Text(AppLocalizations.of(context).save,
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar(Map<String, dynamic> user, String baseUrl) {
    String avatarUrl = user['avatar'] ?? '';

    // Check if avatarUrl is a single character, indicating no image
    bool hasImage = avatarUrl.length > 1;
    log(avatarUrl + baseUrl + "999999999999999999999999999");

    return hasImage
        ? CircleAvatar(
            backgroundImage: NetworkImage("$baseUrl$avatarUrl"),
          )
        : CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              user["avatar"], // Use initials as fallback
              style: const TextStyle(color: Colors.white),
            ),
          );
  }
}
