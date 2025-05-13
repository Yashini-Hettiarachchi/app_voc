import 'package:chat_app/constants/env.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PreviousDifferenceRecordsScreen extends StatefulWidget {
  @override
  _PreviousDifferenceRecordsScreenState createState() =>
      _PreviousDifferenceRecordsScreenState();
}

class _PreviousDifferenceRecordsScreenState
    extends State<PreviousDifferenceRecordsScreen> {
  List<dynamic> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDiffRecords();
  }

  Future<void> _fetchDiffRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('authEmployeeID') ?? "sampleUser";

    final response = await http.get(
      Uri.parse(ENVConfig.serverUrl+'/difference-identifications/user/$username'),
    );

    if (response.statusCode == 200) {
      // final data = jsonDecode(response.body);
      setState(() {
        records = jsonDecode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/fb3f8dc3b3e13aebe66e9ae3df8362e9.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              child: AppBar(
                backgroundColor: Colors.transparent, // Transparent background
                elevation: 0, // Remove shadow
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vocabulary Activity Summary',
                      style: TextStyle(
                        fontSize: 20, // Main title font size
                        color: Colors.black, // Text color
                      ),
                    ),
                    const SizedBox(height: 4), // Space between title and subtitle
                    const Text(
                      'Difficulty ',
                      style: TextStyle(
                        fontSize: 14, // Subtitle font size
                        fontWeight: FontWeight.normal,
                        color: Colors.black, // Text color
                      ),
                    ),
                  ],
                ),
                titleSpacing: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff80ca84), // Background color for the circle
                    shape: BoxShape.circle, // Circular shape
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orangeAccent.withOpacity(0.6), // Glow effect
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white), // Back icon
                    onPressed: () {
                      Navigator.pop(context); // Navigate back
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xff80ca84), // Background color for the circle
                      shape: BoxShape.circle, // Circular shape
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.6), // Glow effect
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white), // Logout icon
                      onPressed: () async {
                        Provider.of<SessionProvider>(context, listen: false)
                            .clearSession();
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        await prefs.clear(); // Clear all stored preferences
                        Navigator.pushReplacementNamed(context, '/landing');
                      },
                    ),
                  ),
                ],
              ),
            ),

            // List of Records
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : records.isEmpty
                  ? const Center(child: Text('No records found'))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  int seconds = record['time_taken'];
                  int minutes = seconds ~/ 60;
                  int remainingSeconds = seconds % 60;
                  DateTime dateTime = DateTime.parse(record['recorded_date']);
                  String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);

                  return Card(
                    elevation: 4,
                    color: Color(0xff27a5c6),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        "Activity: ${record['activity']}",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Type: ${record['type']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Score: ${record['accuracy']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Time Taken: $minutes min $remainingSeconds sec",
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Difference Level: ${record['difficulty']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          // Text(
                          //   "Suggestions: ${record['suggestions']}",
                          //   style: const TextStyle(fontSize: 16),
                          // ),
                          Text(
                            "Date: $formattedDate",
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }
}
