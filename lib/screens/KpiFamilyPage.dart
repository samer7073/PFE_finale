import 'package:flutter/material.dart';
import 'package:flutter_application_stage_project/models/KpiFamily/KpiResponseModel.dart';
import 'package:flutter_application_stage_project/models/KpiFamily/StageKpiModel.dart';
import 'package:flutter_application_stage_project/services/ApiKpiFamily.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class KpiFamilyPage extends StatefulWidget {
  final String family_id;
  const KpiFamilyPage({Key? key, required this.family_id}) : super(key: key);

  @override
  _KpiFamilyPageState createState() => _KpiFamilyPageState();
}

class _KpiFamilyPageState extends State<KpiFamilyPage> {
  late Future<KpiResponseModel> _futureKpiResponse;
  late ThemeProvider themeProvider;

  @override
  void initState() {
    super.initState();
    _futureKpiResponse = ApiKpiFamily.getKpiFamily(widget.family_id);
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<KpiResponseModel>(
        future: _futureKpiResponse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Text("data");
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  
}
