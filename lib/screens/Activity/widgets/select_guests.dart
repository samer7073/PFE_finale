import 'dart:developer';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';

class GuestsSelectionSheet extends StatefulWidget {
  final List<dynamic> guests;
  final List<dynamic> selectedGuests;

  const GuestsSelectionSheet({
    required this.guests,
    required this.selectedGuests,
  });

  @override
  _GuestsSelectionSheetState createState() => _GuestsSelectionSheetState();
}

class _GuestsSelectionSheetState extends State<GuestsSelectionSheet> {
  late List<dynamic> _selectedGuests;
  List<dynamic> _filteredGuests = [];
  final TextEditingController _searchController = TextEditingController();
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _selectedGuests = List.from(widget.selectedGuests);
    _filteredGuests = widget.guests;
    _searchController.addListener(_filterGuests);
    _imageUrlFuture = _loadImageUrl();
  }

  Future<String> _loadImageUrl() async {
    try {
      final url = await Config.getApiUrl("urlImage");

      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load image URL: $e',style: TextStyle(color: Colors.white),)),
        );
      }
      return ''; // Retourner une chaîne vide en cas d'échec
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterGuests);
    _searchController.dispose();
    super.dispose();
  }

  void _filterGuests() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredGuests = widget.guests.where((guest) {
        final name = guest['label'].toLowerCase();
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
          return Center(child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
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
                  hintText: 'Search Guests',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredGuests.length,
                itemBuilder: (context, index) {
                  final guest = _filteredGuests[index];
                  final isSelected = _selectedGuests.contains(guest);
                  return CheckboxListTile(
                    activeColor: Colors.blue,
                    secondary: _buildAvatar(guest, imageUrl),
                    title: Text(guest['label']),
                    subtitle: Text(guest['family_name'] ?? ""),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedGuests.add(guest);
                        } else {
                          _selectedGuests.remove(guest);
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
                Navigator.pop(context, _selectedGuests);
              },
              child: Text(AppLocalizations.of(context)!.save,
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

    return hasImage
        ? CircleAvatar(
            backgroundImage: NetworkImage("$baseUrl$avatarUrl"),
          )
        : CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(
              avatarUrl.toUpperCase(), // Use the single letter as initial
              style: const TextStyle(color: Colors.white),
            ),
          );
  }
}
