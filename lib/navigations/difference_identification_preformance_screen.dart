import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:math';

class VocabularyPerformanceScreen extends StatefulWidget {
  @override
  _VocabularyPerformanceScreenState createState() =>
      _VocabularyPerformanceScreenState();
}

class _VocabularyPerformanceScreenState
    extends State<VocabularyPerformanceScreen> {
  bool isLoading = true;
  List<dynamic> records = [];
  List<FlSpot> scorePoints = [];

  @override
  void initState() {
    super.initState();
    _fetchVocabularyRecords();
  }

  Future<void> _fetchVocabularyRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('authEmployeeID') ?? "sampleUser";

    final response = await http.get(
      Uri.parse(ENVConfig.serverUrl + '/vocabulary-records/user/$username'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        records = data['records'];
        scorePoints = _generateScorePoints(records);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load vocabulary records')),
      );
    }
  }

  List<FlSpot> _generateScorePoints(List<dynamic> records) {
    List<FlSpot> points = [];
    for (int i = 0; i < records.length; i++) {
      double score = _sanitizeScore(records[i]['score']);
      points.add(FlSpot(i.toDouble(), score));
    }
    return points;
  }

  double _sanitizeScore(dynamic score) {
    if (score == null) return 0.0;
    double parsedScore = (score as num?)?.toDouble() ?? 0.0;
    if (parsedScore.isNaN || parsedScore.isInfinite) {
      return 0.0;
    }
    return parsedScore;
  }

  String _getGrade(double score) {
    if (score >= 90) return "Platinum";
    if (score >= 75) return "Gold";
    if (score >= 60) return "Silver";
    if (score >= 45) return "Bronze";
    return "Initial";
  }

  String _getLevel(double score) {
    if (score >= 90) return "Level 4";
    if (score >= 70) return "Level 3";
    if (score >= 50) return "Level 2";
    return "Level 1";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vocabulary Performance'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchVocabularyRecords,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : records.isEmpty
          ? Center(child: Text('No records found'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: scorePoints,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Your Grade: ${_getGrade(_sanitizeScore(records.last['score']))}",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "Your Level: ${_getLevel(_sanitizeScore(records.last['score']))}",
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
