import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/core/constants/shared/config.dart';

import 'package:flutter_application_stage_project/models/leads_models/lead.dart';
import 'package:flutter_application_stage_project/screens/leads/leadTile.dart';
import 'package:flutter_application_stage_project/services/leadsService.dart/leadServise.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  List<Lead> leads = [];
  bool isLoading = false;
  bool hasMore = true;
  int page = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  Timer? _debounce;

  bool _showExtraButtons = false;

  @override
  void initState() {
    super.initState();
    fetchLeads();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          hasMore) {
        fetchMoreLeads();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = _searchController.text;
        page = 1;
        leads.clear();
        fetchLeads();
      });
    });
  }

  Future<void> fetchLeads() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Lead> fetchedLeads =
          await ServiceLeads.getAllLeads(page: page, search: searchQuery);
      setState(() {
        leads.addAll(fetchedLeads);
        isLoading = false;
        hasMore = fetchedLeads.length == 10;
      });
    } catch (error) {
      log('Error fetching Leads: $error');
      setState(() {
        isLoading = false;
        hasMore = false;
      });
    }
  }

  Future<void> fetchMoreLeads() async {
    if (!isLoading && hasMore) {
      page++;
      await fetchLeads();
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
        title: Text("Leads"),
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
                  fetchMoreLeads();
                }
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: leads.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < leads.length) {
                    final lead = leads[index];
                    return LeadTile(lead: lead);
                  } else {
                    return Center(
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.blue)
                          : SizedBox.shrink(),
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
