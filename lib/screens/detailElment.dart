// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/screens/detailPage.dart';

import 'ActivityElmentPage.dart';
import 'RoomCommenatire.dart';
import 'loading.dart';
import 'overview_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DetailElment extends StatefulWidget {
  final String idElment;
  final String idFamily;
  final String roomId;
  final String refenrce;
  final String label;
  final int pipeline_id;
  const DetailElment(
      {super.key,
      required this.idElment,
      required this.idFamily,
      required this.roomId,
      required this.label,
      required this.refenrce,
      required this.pipeline_id});

  @override
  State<DetailElment> createState() => _DetailElmentState();
}

class _DetailElmentState extends State<DetailElment>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.refenrce),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.details),
            Tab(text: AppLocalizations.of(context)!.overview),
            Tab(text: AppLocalizations.of(context)!.comment),
            Tab(text: AppLocalizations.of(context)!.activity),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          DetailPage(
              elementId: widget.idElment, pipeline_id: widget.pipeline_id),
          OverviewPage(elementId: widget.idElment, familyId: widget.idFamily),
          RommCommanitairePage(roomId: widget.roomId),
          ActivityElmentPage(idElment: widget.idElment),
        ],
      ),
    );
  }
}
