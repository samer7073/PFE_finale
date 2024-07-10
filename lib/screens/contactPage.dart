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

  @override
  void initState() {
    super.initState();
    fetchContacts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).contacts),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Organisation...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                prefixIcon: const Icon(Icons.search),
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
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
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
    return ListTile(
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
                    return CircularProgressIndicator();
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
      title: Text(contact.label),
      subtitle: Text(contact.familyLabel),
    );
  }
}
