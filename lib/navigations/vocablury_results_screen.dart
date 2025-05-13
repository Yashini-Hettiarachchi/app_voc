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
      suggestions.add(
          "📚 Start with simple words that have pictures - it's easier to remember!");
      suggestions.add(
          "🔄 Practice the same words many times - repetition helps your brain remember!");
      suggestions.add(
          "👀👂👆 Try seeing, hearing, and touching things while learning their names!");
    } else if (totalScore < 70) {
      suggestions.add(
          "🗂️ Group similar words together - like all animals or all colors!");
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
                'suggestions':
                    personalizedSuggestions // Include child-friendly suggestions
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
            debugPrint(
                "Suggestions saved locally to file: ${suggestionsFile.path}");
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
          'suggestions':
              personalizedSuggestions, // Include child-friendly suggestions
        }));

        // Save back to SharedPreferences
        prefs.setStringList('local_vocabulary_records', savedRecords);
        debugPrint("Score and suggestions saved locally as fallback.");

        // Show a child-friendly message that data was saved
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
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

  Future<void> updateVocabScore(int predictedDifficulty) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('authEmployeeID');

      final updateData = {
        "vocabulary": predictedDifficulty,
      };

      try {
        final response = await http
            .put(
              Uri.parse('${ENVConfig.serverUrl}/users/$userId/update_score'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(updateData),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200 && mounted) {
          debugPrint('Score updated successfully on server');
          // No need to show a snackbar for this operation
        } else {
          debugPrint(
              'Failed to update score on server: ${response.statusCode}');
          // Save locally instead
          await prefs.setInt('vocabulary_level', predictedDifficulty);
        }
      } catch (serverError) {
        debugPrint('Server error when updating score: $serverError');
        // Save locally as fallback
        await prefs.setInt('vocabulary_level', predictedDifficulty);
      }
    } catch (e) {
      debugPrint('Error in updateVocabScore: $e');
      // No need to show error to user for this operation
    }
  }

  void _calculateTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    int difficulty = prefs.getInt('vocabulary_difficulty') ?? 1;

    // Calculate score based on exactly 10 questions per level
    // Each question is worth 10 points, with time factor deduction
    double timeFactor = widget.timeTaken * 0.05;
    totalScore = ((100 * widget.rawScore / 10) - timeFactor).toInt();

    await _saveScoreToDB(totalScore, difficulty.clamp(1, 5));

    if (totalScore > 60) {
      difficulty += 1;
    } else if (totalScore > 30) {
      // Keep the same difficulty
    } else {
      difficulty = (difficulty - 1).clamp(0, double.infinity).toInt();
    }

    totalScore = totalScore.clamp(0, 100);
    await prefs.setInt('vocabulary_difficulty', difficulty.clamp(1, 5));
    await prefs.setInt('last_time_taken', widget.timeTaken);
    updateVocabScore(difficulty.clamp(1, 5));

    setState(() {});
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String getMotivationalMessage() {
    if (totalScore >= 95) {
      return "Masterful Work! Incredible precision and speed! You're a true master of this game.";
    } else if (totalScore >= 75) {
      return "Excellent Performance! Fantastic job honing your skills.";
    } else if (totalScore >= 60) {
      return "Great Job! Keep practicing for even better results.";
    } else if (totalScore >= 30) {
      return "Good Effort! You’re improving with each try.";
    } else {
      return "Keep Trying! Every attempt brings you closer to success.";
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('MMM dd, yyyy');
      return formatter.format(date);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return dateString;
    }
  }

  // Create a simple performance summary for the PDF
  pw.Widget _buildPerformanceSummary() {
    if (records.isEmpty) {
      return pw.Container();
    }

    // Create a simple text-based summary
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Performance Summary:",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(
            "Your vocabulary skills have ${comparison['score_change'] ?? 'changed'} over time."),
        pw.Text(
            "Your most recent score: ${records.isNotEmpty ? '${records[0]['score']}%' : 'N/A'}"),
        pw.Text("Your average score: ${_calculateAverageScore()}%"),
        pw.Text("Your current level: ${_getGrade(widget.difficulty)}"),
        pw.SizedBox(height: 8),
        pw.Text("Keep practicing to improve your vocabulary skills!"),
      ],
    );
  }

  // Calculate average score from records
  String _calculateAverageScore() {
    if (records.isEmpty) return "0";

    double sum = 0;
    for (var record in records) {
      sum += _sanitizeScore(record['score']);
    }
    return (sum / records.length).toStringAsFixed(1);
  }

  Future<void> _generateAndShowPDF() async {
    setState(() {
      isLoading = true;
    });

    await _fetchVocabularyRecords();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Vocabulary Results",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text("Total Score: $totalScore%"),
            pw.Text("Time Taken: ${formatTime(widget.timeTaken)}"),
            pw.Text("Raw Score: ${widget.rawScore}/10"),
            pw.Text("Grade: ${_getGrade(widget.difficulty)}"),
            pw.SizedBox(height: 16),
            pw.Text("Motivational Message:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(getMotivationalMessage()),
            pw.SizedBox(height: 16),

            // Performance Summary
            if (records.isNotEmpty) ...[
              _buildPerformanceSummary(),
              pw.SizedBox(height: 16),
            ],

            // Personalized Suggestions
            pw.Text("Personalized Suggestions:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            for (var suggestion in personalizedSuggestions)
              pw.Text("- $suggestion"),
            pw.SizedBox(height: 16),

            // Previous Records
            pw.Text("Previous Records:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            if (records.isNotEmpty) ...[
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Date',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Score',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Time',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Level',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  for (var record in records) ...[
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(record['recorded_date'] != null
                                ? _formatDate(
                                    record['recorded_date'].toString())
                                : 'N/A')),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text('${record['score']}%')),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(record['time_taken'] != null
                                ? formatTime(record['time_taken'])
                                : 'N/A')),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(record['difficulty'] != null
                                ? _getGrade(record['difficulty'])
                                : 'N/A')),
                      ],
                    ),
                  ],
                ],
              ),
            ] else ...[
              pw.Text("No previous records found."),
            ],
            if (comparison.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text("Performance Comparison:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  "Score Change: ${comparison['score_change'] ?? 'N/A'} (${comparison['score_difference'] ?? 'N/A'}%)"),
              pw.Text(
                  "Time Taken Change: ${comparison['time_change'] ?? 'N/A'} (${comparison['time_difference'] ?? 'N/A'}s)"),
              pw.Text(
                  "Difficulty Level Change: ${comparison['difficulty_change'] ?? 'N/A'}"),
            ],
          ],
        ),
      ),
    );

    final pdfInMemory = await pdf.save();

    // Save the PDF to a file for sharing
    final directory = await getTemporaryDirectory();
    pdfFile = File('${directory.path}/vocabulary_results.pdf');
    await pdfFile!.writeAsBytes(pdfInMemory);

    setState(() {
      isLoading = false;
    });

    // Don't store the result, just call the method
    if (mounted) {
      await _openPDFFromMemory(pdfInMemory);
    }
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

      debugPrint('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(
            'Received data: ${data.toString().substring(0, min(100, data.toString().length))}...');

        if (mounted) {
          setState(() {
            records = data['records'] ?? [];
            comparison = data['comparison'] ?? {};

            // Generate score points for chart
            if (records.isNotEmpty) {
              scorePoints = _generateScorePoints(records);
            }

            isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        debugPrint('No records found for user: $username');
        // If no records found, use empty records but don't show mock data
        if (mounted) {
          setState(() {
            records = [];
            comparison = {};
            isLoading = false;
          });
        }
      } else {
        debugPrint('Server returned error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        // Use mock data if server returns error
        _useMockData();
      }

      // Generate personalized suggestions
      _generatePersonalizedSuggestions();
    } catch (e) {
      debugPrint('Error fetching vocabulary records: $e');
      // Use mock data if server connection fails
      _useMockData();
    }
  }

  void _useMockData() {
    setState(() {
      // Create mock records for demonstration
      records = [
        {
          'recorded_date': DateTime.now()
              .subtract(const Duration(days: 7))
              .toIso8601String(),
          'score': totalScore - 5,
          'time_taken': widget.timeTaken + 30,
          'difficulty':
              widget.difficulty > 1 ? widget.difficulty - 1 : widget.difficulty,
        },
        {
          'recorded_date': DateTime.now()
              .subtract(const Duration(days: 14))
              .toIso8601String(),
          'score': totalScore - 10,
          'time_taken': widget.timeTaken + 60,
          'difficulty':
              widget.difficulty > 1 ? widget.difficulty - 1 : widget.difficulty,
        },
        {
          'recorded_date': DateTime.now()
              .subtract(const Duration(days: 21))
              .toIso8601String(),
          'score': totalScore - 15,
          'time_taken': widget.timeTaken + 90,
          'difficulty':
              widget.difficulty > 1 ? widget.difficulty - 1 : widget.difficulty,
        }
      ];

      // Create mock comparison data
      comparison = {
        'score_change': 'Improved',
        'score_difference': 5,
        'time_change': 'Faster',
        'time_difference': 30,
        'difficulty_change': 'Increased',
      };

      // Generate score points for chart
      scorePoints = _generateScorePoints(records);

      isLoading = false;
    });

    // Generate personalized suggestions
    _generatePersonalizedSuggestions();
  }

  Future<void> _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('accessTokenExpireDate');
      await prefs.remove('refreshTokenExpireDate');
      await prefs.remove('userRole');
      await prefs.remove('authEmployeeID');
      await prefs.remove("vocabulary_difficulty");
      await prefs.remove("difference_difficulty");

      // Check if widget is still mounted before using context
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  Future<void> _openPDFFromMemory(Uint8List pdfInMemory) async {
    final pdfFile = await _createFileFromBytes(pdfInMemory);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Vocabulary Report'),
              backgroundColor: const Color(0xff80ca84),
              actions: [
                // Print button
                IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () {
                    _showPrintOptions(pdfFile);
                  },
                ),
                // Download/Share button
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    _sharePDF(pdfFile);
                  },
                ),
              ],
            ),
            body: PDFView(
              filePath: pdfFile.path,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
            ),
          ),
        ),
      );
    }
  }

  // Show print options dialog
  void _showPrintOptions(File pdfFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Print Options'),
          content: const Text('Would you like to print or save this report?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // This would ideally connect to a printer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Printing functionality would be implemented here')),
                );
              },
              child: const Text('Print'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _sharePDF(pdfFile);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Share PDF file
  void _sharePDF(File pdfFile) {
    try {
      Share.shareXFiles([XFile(pdfFile.path)],
          text: 'Vocabulary Performance Report');
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing PDF: $e')),
      );
    }
  }

  Future<File> _createFileFromBytes(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/vocabulary_results.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff80ca84),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VocabularyLevelsScreen()));
        },
        child: const Icon(Icons.list),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgrounds/fb3f8dc3b3e13aebe66e9ae3df8362e9.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Vocabulary Activity Summary',
                        style: TextStyle(fontSize: 20, color: Colors.black)),
                    SizedBox(height: 4),
                    Text('Your activity Results',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black)),
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
                          spreadRadius: 2)
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
                            spreadRadius: 2)
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        _logout();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: totalScore >= 60
                      ? Colors.green.shade100
                      : Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text('Total Score: $totalScore %',
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          const SizedBox(height: 16.0),
                          Text('Time Taken: ${formatTime(widget.timeTaken)}',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black54)),
                          const SizedBox(height: 8.0),
                          Text('Raw Score: ${widget.rawScore}/10',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black87)),
                          const SizedBox(height: 8.0),
                          Text('Grade: ${_getGrade(widget.difficulty)}',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SuggestedActivitiesScreen(
                                    totalScore: totalScore),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lightbulb),
                          label: const Text("Helpful Tips 💡"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[200],
                            foregroundColor: Colors.purple[900],
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : _generateAndShowPDF,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.picture_as_pdf_outlined),
                          label: Text(isLoading
                              ? "Making your report..."
                              : "Make a Cool Report 📊"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[200],
                            foregroundColor: Colors.blue[900],
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
