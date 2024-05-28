import 'package:flutter/material.dart';

class GuestsSelectionSheet extends StatefulWidget {
  final List<dynamic> guests;
  final List<dynamic> selectedGuests;

  const GuestsSelectionSheet({required this.guests, required this.selectedGuests});

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
                activeColor: Colors.purple,
                secondary: CircleAvatar(
                  child: Text(
                    _getInitials(guest['label']),
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: const Color.fromARGB(255, 240, 209, 246),
                ),
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
    backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 240, 209, 246)),
  ),
          onPressed: () {
            Navigator.pop(context, _selectedGuests);
          },
          child: Text('Done', style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}