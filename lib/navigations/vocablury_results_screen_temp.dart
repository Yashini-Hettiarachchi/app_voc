import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/navigations/suggested_activities_screen.dart';
import 'package:chat_app/navigations/vocabulary_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';

class VocabularyResultsScreen extends StatefulWidget {
  final int rawScore;
  final int timeTaken;
  final int difficulty;
  final Map<String, dynamic> levelData;
  final bool autoGenerateReport;

  const VocabularyResultsScreen({
    required this.rawScore,
    required this.timeTaken,
    required this.difficulty,
    required this.levelData,
    this.autoGenerateReport = false,
    Key? key,
  }) : super(key: key);

  @override
  _VocabularyResultsScreenState createState() =>
      _VocabularyResultsScreenState();
}

class _VocabularyResultsScreenState extends State<VocabularyResultsScreen> {
  late int totalScore = 0;
  List<dynamic> records = [];
  bool isLoading = true;
  bool isPrinting = false;
  File? pdfFile;
  List<FlSpot> scorePoints = [];
  Map<String, dynamic> comparison = {
    'score_change': 'N/A',
    'score_difference': 0,
    'time_change': 'N/A',
    'time_difference': 0,
    'difficulty_change': 'N/A',
  };

  // Personalized suggestions based on performance
  List<String> personalizedSuggestions = [];

  @override
  void initState() {
    super.initState();
    _calculateTotalScore();

    // If autoGenerateReport is true, generate the report after a short delay
    if (widget.autoGenerateReport) {
      // Wait for the UI to build and data to be loaded
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _generateAndShowPDF();
        }
      });
    }
  }

  // Generate personalized suggestions based on performance with child-friendly language and emojis
  void _generatePersonalizedSuggestions() {
    // Base suggestions that apply to everyone - child-friendly with emojis
    List<String> suggestions = [
      "🌟 Try to practice words every day - it's like watering a plant to help it grow!",
      "🎴 Make fun flashcards with pictures to help remember new words!",
      "🏆 Give yourself a high-five or sticker when you learn new words!",
    ];

    // Add score-based suggestions with child-friendly language
    if (totalScore < 40) {
      suggestions
          .add("📚 Start with simple words that have pictures - it's easier to remember!");
      suggestions.add(
          "🔄 Practice the same words many times - repetition helps your brain remember!");
      suggestions.add(
          "👀👂👆 Try seeing, hearing, and touching things while learning their names!");
    } else if (totalScore < 70) {
      suggestions
          .add("🗂️ Group similar words together - like all animals or all colors!");
      suggestions.add("🗣️ Try using new words in short, fun sentences!");
      suggestions.add(
          "🎮 Play word games with friends or family - learning can be fun!");
    } else {
      suggestions.add(
          "🚀 You're doing great! Try learning some bigger, more exciting words!");
      suggestions.add("📝 Make up stories using your new words - be creative!");
      suggestions
          .add("🔍 Find out where words come from - some have cool histories!");
    }

    // Add time-based suggestions with child-friendly language
    if (widget.timeTaken > 300) {
      // More than 5 minutes
      suggestions.add("⏱️ Try to focus a little more - maybe set a fun timer!");
      suggestions.add(
          "⏲️ Short practice times work best - like 10-minute word adventures!");
    }

    // Add difficulty-based suggestions with child-friendly language
    if (widget.difficulty <= 2) {
      suggestions.add(
          "🪜 You're doing great! Soon you'll be ready for slightly harder words!");
    } else if (widget.difficulty >= 4) {
      suggestions.add(
          "🌈 Keep challenging yourself with new words, but remember to have fun!");
    }

    personalizedSuggestions = suggestions;
  }

  // Generate score points for the chart
  List<FlSpot> _generateScorePoints(List<dynamic> records) {
    List<FlSpot> points = [];
    for (int i = 0; i < records.length; i++) {
      double score = _sanitizeScore(records[i]['score']);
      points.add(FlSpot(i.toDouble(), score));
    }
    return points;
  }

  // Helper to safely convert score to double
  double _sanitizeScore(dynamic score) {
    if (score == null) return 0.0;
    try {
      double parsedScore =
          (score is num) ? score.toDouble() : double.parse(score.toString());
      if (parsedScore.isNaN || parsedScore.isInfinite) {
        return 0.0;
      }
      return parsedScore;
    } catch (e) {
      debugPrint('Error parsing score: $e');
      return 0.0;
    }
  }

  String _getGrade(int difficulty) {
    switch (difficulty) {
      case 0:
        return "Initial";
      case 1:
        return "Initial";
      case 2:
        return "Bond";
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

  Future<void> _saveScoreToDB(int score, int difficulty) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String user = prefs.getString('authEmployeeID') ?? "sampleUser";
      
      // Generate personalized suggestions if not already generated
      if (personalizedSuggestions.isEmpty) {
        _generatePersonalizedSuggestions();
      }

      // Try to save to server with timeout
      try {
        final response = await http
            .post(
              Uri.parse('${ENVConfig.serverUrl}/vocabulary-records'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer YOUR_ACCESS_TOKEN',
              },
              body: jsonEncode({
                'score': score,
                'difficulty': difficulty,
                'user': user,
                'activity': widget.levelData['title'] ?? 'Vocabulary Activity',
                'type': widget.levelData['type'] ?? 'basic',
                'time_taken': widget.timeTaken,
                'recorded_date': DateTime.now().toIso8601String(),
                'suggestions': personalizedSuggestions // Include child-friendly suggestions
              }),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          debugPrint("Score and suggestions saved successfully to server.");
          
          // Create a directory to save suggestions locally as well
          try {
            Directory dir = await getApplicationDocumentsDirectory();
            String path = '${dir.path}/vocabulary_suggestions';
            Directory suggestionsDir = Directory(path);
            if (!await suggestionsDir.exists()) {
              await suggestionsDir.create(recursive: true);
            }
            
            // Save suggestions to a file with timestamp
            String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
            File suggestionsFile = File('$path/suggestions_$timestamp.json');
            await suggestionsFile.writeAsString(jsonEncode({
              'score': score,
              'suggestions': personalizedSuggestions,
              'date': DateTime.now().toIso8601String()
            }));
            debugPrint("Suggestions saved locally to file: ${suggestionsFile.path}");
          } catch (fileError) {
            debugPrint("Error saving suggestions to file: $fileError");
          }
        } else {
          debugPrint("Server returned error: ${response.statusCode}");
          // Save locally as fallback
          _saveScoreLocally(score, difficulty, user);
        }
      } catch (serverError) {
        debugPrint("Could not connect to server: $serverError");
        // Save locally as fallback
        _saveScoreLocally(score, difficulty, user);
      }
    } catch (e) {
      debugPrint("Error in _saveScoreToDB: $e");
    }
  }

  void _saveScoreLocally(int score, int difficulty, String user) {
    try {
      // Generate personalized suggestions if not already generated
      if (personalizedSuggestions.isEmpty) {
        _generatePersonalizedSuggestions();
      }
      
      // Save to SharedPreferences as a fallback
      SharedPreferences.getInstance().then((prefs) {
        // Get existing records or create new list
        List<String> savedRecords =
            prefs.getStringList('local_vocabulary_records') ?? [];

        // Add new record with suggestions
        savedRecords.add(jsonEncode({
          'score': score,
          'difficulty': difficulty,
          'user': user,
          'activity': widget.levelData['title'] ?? 'Vocabulary Activity',
          'type': widget.levelData['type'] ?? 'basic',
          'time_taken': widget.timeTaken,
          'recorded_date': DateTime.now().toIso8601String(),
          'suggestions': personalizedSuggestions, // Include child-friendly suggestions
        }));

        // Save back to SharedPreferences
        prefs.setStringList('local_vocabulary_records', savedRecords);
        debugPrint("Score and suggestions saved locally as fallback.");
        
        // Show a child-friendly message that data was saved
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Your progress has been saved! 🎉',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
      
      // Also try to save to a file in the app's documents directory
      getApplicationDocumentsDirectory().then((dir) async {
        try {
          String path = '${dir.path}/vocabulary_records';
          Directory recordsDir = Directory(path);
          if (!await recordsDir.exists()) {
            await recordsDir.create(recursive: true);
          }
          
          // Save record to a file with timestamp
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          File recordFile = File('$path/record_$timestamp.json');
          await recordFile.writeAsString(jsonEncode({
            'score': score,
            'difficulty': difficulty,
            'user': user,
            'activity': widget.levelData['title'] ?? 'Vocabulary Activity',
            'type': widget.levelData['type'] ?? 'basic',
            'time_taken': widget.timeTaken,
            'recorded_date': DateTime.now().toIso8601String(),
            'suggestions': personalizedSuggestions,
          }));
          debugPrint("Record saved to file: ${recordFile.path}");
        } catch (fileError) {
          debugPrint("Error saving record to file: $fileError");
        }
      });
    } catch (e) {
      debugPrint("Error saving score locally: $e");
    }
  }
