import 'package:flutter/material.dart';

class GuestsSelectionSheet extends StatefulWidget {
  final List<dynamic> guests;
  final List<dynamic> selectedGuests;

  const GuestsSelectionSheet(
      {required this.guests, required this.selectedGuests});

  @override
  _GuestsSelectionSheetState createState() => _GuestsSelectionSheetState();
}

class _GuestsSelectionSheetState extends State<GuestsSelectionSheet> {
  late List<dynamic> _selectedGuests;
  List<dynamic> _filteredGuests = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedGuests = List.from(widget.selectedGuests);
    _filteredGuests = widget.guests;
    _searchController.addListener(_filterGuests);
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
                secondary: _buildAvatar(guest),
                title: Text(guest['label']),
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
                const Color.fromARGB(255, 58, 119, 216)),
          ),
          onPressed: () {
            Navigator.pop(context, _selectedGuests);
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
