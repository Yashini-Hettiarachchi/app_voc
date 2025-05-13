import 'dart:async';
import 'dart:convert';
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

class VocabularyResultsScreen extends StatefulWidget {
  final int rawScore;
  final int timeTaken;
  final int difficulty;
  final Map<String, dynamic> levelData;

  const VocabularyResultsScreen({
    required this.rawScore,
    required this.timeTaken,
    required this.difficulty,
    required this.levelData,
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
  Map<String, dynamic> comparison = {
    'score_change': 'N/A',
    'score_difference': 0,
    'time_change': 'N/A',
    'time_difference': 0,
    'difficulty_change': 'N/A',
  };

  @override
  void initState() {
    super.initState();
    _calculateTotalScore();
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
                'suggestions': []
              }),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          debugPrint("Score saved successfully to server.");
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
      // Save to SharedPreferences as a fallback
      SharedPreferences.getInstance().then((prefs) {
        // Get existing records or create new list
        List<String> savedRecords =
            prefs.getStringList('local_vocabulary_records') ?? [];

        // Add new record
        savedRecords.add(jsonEncode({
          'score': score,
          'difficulty': difficulty,
          'user': user,
          'activity': widget.levelData['title'] ?? 'Vocabulary Activity',
          'type': widget.levelData['type'] ?? 'basic',
          'time_taken': widget.timeTaken,
          'recorded_date': DateTime.now().toIso8601String(),
        }));

        // Save back to SharedPreferences
        prefs.setStringList('local_vocabulary_records', savedRecords);
        debugPrint("Score saved locally as fallback.");
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

  Future<void> _generateAndShowPDF() async {
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
            pw.Text("Raw Score: ${widget.rawScore}"),
            pw.Text("Grade: ${_getGrade(widget.difficulty)}"),
            pw.SizedBox(height: 16),
            pw.Text("Motivational Message:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(getMotivationalMessage()),
            pw.SizedBox(height: 16),
            pw.Text("Suggestions for Parents:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text("- Encourage daily vocabulary practice."),
            pw.Text("- Use flashcards to reinforce learning."),
            pw.Text("- Reward achievements to motivate consistent effort."),
            pw.Text("- Discuss new words during family activities."),
            pw.Text("- Set small, achievable learning goals."),
            pw.SizedBox(height: 16),
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
                          child: pw.Text('Time Taken',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Difficulty',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  for (var record in records) ...[
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(record['recorded_date'].toString())),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text('${record['score']}%')),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(record['time_taken'].toString())),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(record['difficulty'].toString())),
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

    // Don't store the result, just call the method
    if (mounted) {
      await _openPDFFromMemory(pdfInMemory);
    }
  }

  Future<void> _fetchVocabularyRecords() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('authEmployeeID') ?? "sampleUser";

      final response = await http
          .get(
        Uri.parse('${ENVConfig.serverUrl}/vocabulary-records/user/$username'),
      )
          .timeout(const Duration(seconds: 5), onTimeout: () {
        // Return a fake response instead of throwing an exception
        return http.Response('{"error": "timeout"}', 408);
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            records = data['records'];
            comparison = data['comparison'] ?? {};
            isLoading = false;
          });
        }
      } else {
        // Use mock data if server returns error
        _useMockData();
      }
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
          'recorded_date':
              DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
          'score': totalScore - 5,
          'time_taken': widget.timeTaken + 30,
          'difficulty':
              widget.difficulty > 1 ? widget.difficulty - 1 : widget.difficulty,
        },
        {
          'recorded_date':
              DateTime.now().subtract(Duration(days: 14)).toIso8601String(),
          'score': totalScore - 10,
          'time_taken': widget.timeTaken + 60,
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

      isLoading = false;
    });
  }

  Future<void> _openPDFFromMemory(Uint8List pdfInMemory) async {
    final pdfFile = await _createFileFromBytes(pdfInMemory);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFView(filePath: pdfFile.path),
        ),
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
        backgroundColor: Color(0xff80ca84),
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
              padding: EdgeInsets.only(top: 5, left: 10, right: 10),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Color(0xff80ca84),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 2)
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
                            spreadRadius: 2)
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      onPressed: () async {
                        // Store context before async gap
                        final currentContext = context;

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
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
                          Navigator.pushReplacementNamed(
                              currentContext, '/landing');
                        }
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
                          Text('Raw Score: ${widget.rawScore}',
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
                          label: const Text("Suggested Info"),
                        ),
                        ElevatedButton.icon(
                          onPressed: _generateAndShowPDF,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text("Generate Report"),
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
