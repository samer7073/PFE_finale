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
            return const Center(child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildListView(snapshot.data!);
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Widget _buildListView(KpiResponseModel data) {
    return ListView.builder(
      itemCount: data.data.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    data.data[index].pipeline,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode == true
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
                const SizedBox(height: 10),
                _buildBarChart(data.data[index].stages),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(List<StageKpiModel> stages) {
    double maxValue = _findMaxValue(stages);

    // Ensure horizontalInterval is never zero
    double interval = maxValue > 0 ? maxValue / 4 : 1;

    return AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue > 0 ? maxValue : 1, // Ensure maxY is never zero
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor:
                  themeProvider.isDarkMode == true ? Colors.blue : Colors.blue,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  stages[groupIndex].stageLabel + ":   " + rod.y.toString(),
                  TextStyle(
                      color: themeProvider.isDarkMode == true
                          ? Colors.white
                          : Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: _buildBottomTitles(stages),
            leftTitles: _buildLeftTitles(maxValue),
            rightTitles: SideTitles(showTitles: false),
            topTitles: SideTitles(showTitles: false),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _buildBarGroups(stages),
          gridData: FlGridData(show: false, horizontalInterval: interval),
        ),
      ),
    );
  }

  SideTitles _buildBottomTitles(List<StageKpiModel> stages) {
    return SideTitles(
      showTitles: true,
      getTextStyles: (value) => TextStyle(
        color: themeProvider.isDarkMode == true ? Colors.white : Colors.grey,
        fontSize: 10, // Réduire la taille de la police
        overflow: TextOverflow.fade,
      ),
      margin: 10, // Réduire la marge
      rotateAngle: 15, // Augmenter l'angle de rotation
      getTitles: (value) {
        if (value.toInt() >= 0 && value.toInt() < stages.length) {
          return _truncateText(stages[value.toInt()].stageLabel);
        } else {
          return '';
        }
      },
    );
  }

  String _truncateText(String text, {int maxLength = 8}) {
    if (text.length > maxLength) {
      return '${text.substring(0, maxLength)}...';
    } else {
      return text;
    }
  }

  SideTitles _buildLeftTitles(double maxValue) {
    double midValue = maxValue / 2;

    return SideTitles(
      showTitles: true,
      getTextStyles: (value) => TextStyle(
          color: themeProvider.isDarkMode == true ? Colors.white : Colors.black,
          fontSize: 12),
      margin: 10,
      reservedSize: 40,
      getTitles: (value) {
        if (value == 0) {
          return '0';
        } else if (value == midValue) {
          return midValue.toInt().toString();
        } else if (value == maxValue) {
          return maxValue.toInt().toString();
        } else {
          return '';
        }
      },
    );
  }

  double _findMaxValue(List<StageKpiModel> stages) {
    return stages
        .map((stage) => stage.stageCount)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  List<BarChartGroupData> _buildBarGroups(List<StageKpiModel> stages) {
    return stages.asMap().entries.map((entry) {
      final index = entry.key;
      final stage = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            width: 18,
            y: stage.stageCount.toDouble(),
            colors: [hexToColor(stage.stage_color)],
          ),
        ],
      );
    }).toList();
  }
}