import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/contactModel/data.dart';
import 'package:flutter_application_stage_project/screens/ContactDeatails.dart';
import 'package:flutter_application_stage_project/services/contact/ApiContact.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/constants/shared/config.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Data> contacts = [];
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  Timer? _debounce;

  bool _showExtraButtons = false; // Variable d'état pour les boutons supplémentaires

  @override
  void initState() {
    super.initState();
    fetchContacts(); // Charger les contacts initiaux
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        fetchMoreContacts();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel(); // Annuler le délai lors de la suppression de la page
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = _searchController.text;
        page = 1;
        contacts.clear();
        fetchContacts();
      });
    });
  }

  Future<void> fetchContacts() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Data> fetchedContacts =
          await ApiContact.getAllContact(page: page, search: searchQuery);
      setState(() {
        contacts.addAll(fetchedContacts);
        isLoading = false;
        hasMore = fetchedContacts.length == 10; // Taille de la page est 10
      });
    } catch (error) {
      log('Error fetching contacts: $error');
      setState(() {
        isLoading = false;
        hasMore = false;
      });
    }
  }

  Future<void> fetchMoreContacts() async {
    if (!isLoading && hasMore) {
      page++;
      await fetchContacts();
    }
  }

  void _toggleExtraButtons() {
    setState(() {
      _showExtraButtons = !_showExtraButtons;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.contacts),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchorganisationandcontacts,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
              ),
            ),
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is ScrollEndNotification &&
                    _scrollController.position.extentAfter == 0 &&
                    hasMore) {
                  fetchMoreContacts();
                }
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: contacts.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < contacts.length) {
                    final contact = contacts[index];
                    return ContactTile(contact: contact);
                  } else {
                    // Afficher le CircularProgressIndicator seulement lorsque nous sommes en train de charger plus de contacts
                    return Center(
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.blue)
                          : SizedBox.shrink(), // Afficher rien si pas en train de charger
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _toggleExtraButtons,
              child: Icon(_showExtraButtons ? Icons.close : Icons.add, color: Colors.white),
              backgroundColor: Colors.blue,
            ),
          ),
          if (_showExtraButtons) ...[
            Positioned(
              bottom: 80,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  // Action à exécuter lorsque ce bouton est pressé
                },
                child: Icon(Icons.business, color: Colors.white),
                backgroundColor: Colors.blue,
              ),
            ),
            Positioned(
              bottom: 144,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  // Action à exécuter lorsque ce bouton est pressé
                },
                child: Icon(Icons.person, color: Colors.white),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  final Data contact;

  const ContactTile({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
       color: isDarkMode == false
              ? Color.fromARGB(255, 244, 245, 247)
              : Color.fromARGB(255, 31, 24, 24),
      shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
      elevation: 1,
      child: Padding(
        
        padding: const EdgeInsets.all(6.0),
        child: ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ContactDetailsPage(contactId: contact.id);
              },
            ));
          },
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue,
            child: contact.avatar.length == 1
                ? Text(
                    contact.avatar,
                    style: TextStyle(color: Colors.white),
                  )
                : FutureBuilder<String>(
                    future: Config.getApiUrl('urlImage'),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: Colors.blue,
                        );
                      }
                      if (snapshot.hasError) {
                        return Icon(Icons.error);
                      }
                      if (!snapshot.hasData || snapshot.data == null) {
                        return Icon(Icons.error);
                      }
                      return CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          "${snapshot.data}${contact.avatar}",
                        ),
                      );
                    },
                  ),
          ),
          title: Text(contact.label, style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:isDarkMode? Colors.white :Colors.black87
                        ),),
          subtitle: Row(
            children: [
              if (contact.familyLabel == "Organisation")
                Icon(
                  Icons.business,
                  color: Colors.grey,
                  size: 16,
                )
              else
                Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 16,
                ),
              SizedBox(width: 8),
              Text(contact.familyLabel,style :TextStyle(color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }
}
