// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/contactModel/data.dart';
import 'package:flutter_application_stage_project/screens/ContactDeatails.dart';
import 'package:flutter_application_stage_project/services/contact/ApiContact.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchContacts();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        fetchMoreContacts();
      }
    });
    _searchController.addListener(() {
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
        hasMore = false;
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
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
            child: ListView.builder(
              controller: _scrollController,
              itemCount: contacts.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == contacts.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final contact = contacts[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return ContactDetailsPage(contactId: contact.id);
                      },
                    ));
                  },
                  leading: contact.avatar.length == 1
                      ? CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            contact.avatar,
                            style: TextStyle(color: Colors.white),
                          ),
                          radius: 25,
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(
                              "https://spherebackdev.cmk.biz:4543/storage/uploads/${contact.avatar}"),
                          radius: 25,
                        ),
                  title: Text(contact.label),
                  subtitle: Text(contact.familyLabel),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
