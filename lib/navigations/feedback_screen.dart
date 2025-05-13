import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/difference_levels_screen.dart';
import 'package:chat_app/navigations/puzzle_levels_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../constants/env.dart';
import '../constants/styles.dart';

class FeedbackScreen extends StatefulWidget {
  final String user;
  final String category;
  final int score;
  final int moves;
  final int timeTaken;
  final int difficulty;
  final String madeBy;

  const FeedbackScreen({
    Key? key,
    required this.user,
    required this.category,
    required this.score,
    required this.moves,
    required this.timeTaken,
    required this.difficulty,
    required this.madeBy,
  }) : super(key: key);

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _currentStep = 0;
  List<int> answers = List.filled(5, 5);

  List<String> nvldQuestions = [
    "Rate your difficulty in understanding patterns (1-10):",
    "Rate your ability to follow visual instructions (1-10):",
    "Rate your memory recall ability (1-10):",
    "Rate your focus level during the puzzle (1-10):",
  ];

  Future<void> submitFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int changeIdentificationDifficulty = prefs.getInt('difference_difficulty') ?? 1;
    final feedbackData = {
      "user": widget.user,
      "category": widget.category,
      "answers": answers,
      "score": widget.score,
      "moves": widget.moves,
      "time_taken": widget.timeTaken,
      "difficulty": widget.difficulty,
      "made_by": widget.madeBy,
    };

    try {
      final response = await http.post(
        Uri.parse('${ENVConfig.serverUrl}/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(feedbackData),
      );

      if (response.statusCode == 201) {
        // Predict difficulty after feedback submission
        final predictedDifficulty = await fetchPredictedDifficulty();

        if (predictedDifficulty != null) {
          String message = '';
          if (changeIdentificationDifficulty < predictedDifficulty) {
            message = 'Would you like to reward your level to this predicted value of $predictedDifficulty?';
          } else if (changeIdentificationDifficulty > predictedDifficulty) {
            message = 'Would it be fine to lower your reward level to this predicted value of $predictedDifficulty?';
          } else {
            message = 'Keep it going! Your level is already matching the predicted value of $predictedDifficulty.';
          }
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Thank You for your Participation', style: TextStyle(color: Colors.white70),),
                content: Column(
                  mainAxisSize: MainAxisSize.min, // Ensures the column takes minimal space
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'LEVEL',
                      style: TextStyle(fontSize: 15, color: Colors.white), // Optional styling
                    ),
                    Text(
                      '$predictedDifficulty',
                      style: TextStyle(fontSize: 56, color: Colors.white), // Optional styling
                    ),
                    SizedBox(height: 8), // Spacing between text elements
                    Text(
                      message,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70),
                    ),
                  ],
                ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DifferenceRecognitionLevelsScreen()),
                    );
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await updateIdentifyDifferenceScore(predictedDifficulty);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DifferenceRecognitionLevelsScreen()),
                    );
                  },
                  child: Text('Yes'),
                ),
              ],
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DifferenceRecognitionLevelsScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<int?> fetchPredictedDifficulty() async {
    try {
      final response = await http.post(
        Uri.parse('${ENVConfig.serverUrl}/predict-difficulty'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'answers': answers,
          'score': widget.score,
          'moves': widget.moves,
          'time_taken': widget.timeTaken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final predictedDifficulty = data['predicted_difficulty'];
        return predictedDifficulty != null ? predictedDifficulty.round() : null;
      } else {
        throw Exception('Failed to fetch predicted difficulty');
      }
    } catch (e) {
      print('Error fetching predicted difficulty: $e');
      return null;
    }
  }

  Future<void> updateIdentifyDifferenceScore(int predictedDifficulty) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('authEmployeeID');
      prefs.setInt('difference_difficulty', predictedDifficulty);

      final updateData = {
        "identify_difference": predictedDifficulty,
      };

      final response = await http.put(
        Uri.parse('${ENVConfig.serverUrl}/users/$userId/update_score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Score updated successfully')),
        );
      } else {
        throw Exception('Failed to update score');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating score: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff80ca84),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DifferenceRecognitionLevelsScreen()),
          );
        },
        child: const Icon(Icons.list),
      ),
      backgroundColor: Color(0xff8ebe83),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5, left: 10, right: 10),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identify Difference - Results',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Difficulty Level ${widget.difficulty}',
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
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Color(0xff80ca84),
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
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Color(0xff80ca84),
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
                      icon: Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        Provider.of<SessionProvider>(context, listen: false).clearSession();
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('accessToken');
                        await prefs.remove('refreshToken');
                        await prefs.remove('accessTokenExpireDate');
                        await prefs.remove('refreshTokenExpireDate');
                        await prefs.remove('userRole');
                        await prefs.remove('authEmployeeID');
                        await prefs.remove("vocabulary_difficulty");
                        await prefs.remove("difference_difficulty");
                        Navigator.pushReplacementNamed(context, '/landing');
                      },
                    ),
                  ),
                ],
              ),
            ),
            Stepper(
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < nvldQuestions.length) {
                  setState(() => _currentStep++);
                } else {
                  submitFeedback();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
              steps: [
                for (int i = 0; i < nvldQuestions.length; i++)
                  Step(
                    title: Text('Question ${i + 1}'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nvldQuestions[i]),
                        Slider(
                          value: answers[i].toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: answers[i].toString(),
                          onChanged: (value) {
                            setState(() => answers[i] = value.toInt());
                          },
                        ),
                      ],
                    ),
                    isActive: _currentStep == i,
                  ),
                Step(
                  title: Text('Confirmation'),
                  content: Text(
                    'Press "Continue" to submit your feedback.',
                    style: TextStyle(fontSize: 16),
                  ),
                  isActive: _currentStep == nvldQuestions.length,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
