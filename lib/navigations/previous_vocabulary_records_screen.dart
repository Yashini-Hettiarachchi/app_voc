import 'package:chat_app/constants/env.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PreviousVocabularyRecordsScreen extends StatefulWidget {
  @override
  _PreviousVocabularyRecordsScreenState createState() =>
      _PreviousVocabularyRecordsScreenState();
}

class _PreviousVocabularyRecordsScreenState
    extends State<PreviousVocabularyRecordsScreen> {
  List<dynamic> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVocabularyRecords();
  }

  Future<void> _fetchVocabularyRecords() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('authEmployeeID') ?? "sampleUser";

      debugPrint('Fetching vocabulary records for user: $username');
      debugPrint(
          'URL: ${ENVConfig.serverUrl}/vocabulary-records/user/$username');

      final response = await http
          .get(
        Uri.parse('${ENVConfig.serverUrl}/vocabulary-records/user/$username'),
      )
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('Request timed out');
        // Return a fake response instead of throwing an exception
        return http.Response('{"error": "timeout"}', 408);
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            records = data['records'];
            isLoading = false;
          });
        }
      } else {
        // If server fails, use mock data for demonstration
        _useMockData();
      }
    } catch (e) {
      debugPrint('Error fetching vocabulary records: $e');
      // If any error occurs, use mock data
      _useMockData();
    }
  }

  // Provide mock data when server is unavailable
  void _useMockData() {
    if (mounted) {
      setState(() {
        records = [
          {
            'activity': 'Word Matching',
            'type': 'basic',
            'recorded_date':
                DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
            'score': 85.0,
            'time_taken': 120,
            'difficulty': 1
          },
          {
            'activity': 'Filling Blanks',
            'type': 'basic',
            'recorded_date':
                DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
            'score': 90.0,
            'time_taken': 150,
            'difficulty': 2
          },
          {
            'activity': 'Visual Identification',
            'type': 'basic',
            'recorded_date':
                DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
            'score': 75.0,
            'time_taken': 180,
            'difficulty': 3
          }
        ];
        isLoading = false;
      });
    }
  }

  String _getGrade(int difficulty) {
    switch (difficulty) {
      case 1:
        return "Initial";
      case 2:
        return "Bronze";
      case 3:
        return "Silver";
      case 4:
        return "Gold";
      case 5:
        return "Platinum";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgrounds/fb3f8dc3b3e13aebe66e9ae3df8362e9.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Previous Activities',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Your Learning Journey',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                titleSpacing: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff80ca84),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xff80ca84),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        Provider.of<SessionProvider>(context, listen: false)
                            .clearSession();
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.pushReplacementNamed(context, '/landing');
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Activity Records
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : records.isEmpty
                      ? const Center(
                          child: Text(
                            'No previous activities found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            int seconds = record['time_taken'];
                            int minutes = seconds ~/ 60;
                            int remainingSeconds = seconds % 60;
                            DateTime dateTime =
                                DateTime.parse(record['recorded_date']);
                            String formattedDate =
                                DateFormat('MMM dd, yyyy - hh:mm a')
                                    .format(dateTime);

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff27a5c6),
                                      Color(0xff80ca84),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            record['activity'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white24,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _getGrade(record['difficulty']),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        Icons.scoreboard,
                                        'Score: ${record['score']}%',
                                      ),
                                      _buildInfoRow(
                                        Icons.timer,
                                        'Time: $minutes min $remainingSeconds sec',
                                      ),
                                      _buildInfoRow(
                                        Icons.category,
                                        'Type: ${record['type']}',
                                      ),
                                      _buildInfoRow(
                                        Icons.calendar_today,
                                        'Date: $formattedDate',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
