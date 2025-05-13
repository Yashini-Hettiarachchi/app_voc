import 'dart:convert';

import 'package:chat_app/constants/env.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/difference_levels_screen.dart';
import 'package:chat_app/navigations/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:chat_app/navigations/vocabulary_list_screen.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;

class DifferenceFindResultsScreen extends StatefulWidget {
  final int score;
  final int moves;
  final int difficulty;
  final int timeTaken; // In seconds
  final bool assisted;

  const DifferenceFindResultsScreen({
    required this.score,
    required this.moves,
    required this.difficulty,
    required this.timeTaken,
    required this.assisted,
    Key? key,
  }) : super(key: key);

  @override
  _DifferenceFindResultsScreenState createState() => _DifferenceFindResultsScreenState();
}

class _DifferenceFindResultsScreenState extends State<DifferenceFindResultsScreen> {
  List<dynamic> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initDifficulty();
  }

  Future<void> _saveScoreToDB(int accuracy, int difficulty) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String user = prefs.getString('authEmployeeID') ?? "sampleUser";
      final response = await http.post(
        Uri.parse(ENVConfig.serverUrl+'/difference-identifications'), // Replace with your API URL
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_ACCESS_TOKEN', // Include token if needed
        },
        body: jsonEncode({
          'accuracy': accuracy,
          'difficulty': difficulty,
          'user': user,
          'activity': "Difference Identification Level - " + difficulty.toString(),
          'type': "Objects Identification",
          'time_taken': widget.timeTaken,
          'recorded_date': DateTime.now().toIso8601String(),
          'suggestions': []
        }),
      );

      if (response.statusCode == 201) {
        print("Score saved successfully.");
      } else {
        print("Failed to save score: \${response.statusCode} - \${response.body}");
      }
    } catch (e) {
      print("Error saving score to database: \$e");
    }
  }

  Future<void> _fetchIDRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('authEmployeeID') ?? "sampleUser";

    final response = await http.get(
      Uri.parse(ENVConfig.serverUrl + '/difference-identifications/user/$username'),
    );

    if (response.statusCode == 200) {
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

  Future<void> _initDifficulty() async {
    final prefs = await SharedPreferences.getInstance();
    int difficulty = prefs.getInt('difference_difficulty') ?? 1;
    print("PREF"+difficulty.toString());

    // Save to DB
    await _saveScoreToDB(widget.score, difficulty.clamp(1, 5));

    // Adjust difficulty based on the score
    if (widget.score > 60) {
      difficulty += 1;
    } else if (widget.score > 30) {
      // Keep the same difficulty
    } else {
      difficulty = (difficulty - 1).clamp(0, double.infinity).toInt(); // Ensure lowest is 0
    }
    print(widget.score);
    print(difficulty);

    // Save updated difficulty
    await prefs.setInt('difference_difficulty', difficulty.clamp(1, 5));
    updateIdentifyDifferenceScore(difficulty.clamp(1, 5));

    setState(() {});
  }
  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _generateAndShowPDF() async {
    await _fetchIDRecords();
    final pdf = pw.Document();

    String furtherAdvice = await _fetchNVLDAdvice(widget.score, widget.timeTaken, widget.difficulty);
    await _fetchIDRecords();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "Identify Differences",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text("Score: ${widget.score}"),
            pw.Text("Time Taken: ${formatTime(widget.timeTaken)}"),
            pw.Text("Difficulty Level: ${widget.difficulty}"),
            pw.Text("Moves Made: ${widget.moves}"),
            pw.SizedBox(height: 16),
            pw.Text(
              "Summary:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              widget.assisted
                  ? "You completed the puzzle in assisted mode. Practice more to build independence."
                  : "Your performance shows great attention to detail and cognitive strength!",
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              "Previous Data:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            if (records != null && records.isNotEmpty) ...[
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Score', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Time Taken', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(4),
                        child: pw.Text('Difficulty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  for (var record in records) ...[
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(record['recorded_date'].toString()),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('${record['accuracy']}%'),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(record['time_taken'].toString()),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text(record['difficulty'].toString()),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ] else ...[
              pw.Text("No previous records found."),
            ],
            pw.SizedBox(height: 16),
            pw.Text(
              "Further Advice:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(furtherAdvice),
            pw.SizedBox(height: 16),
            pw.Text(
              "Suggestions for Parents:",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text("- Encourage daily problem-solving activities to improve attention."),
            pw.Text("- Promote teamwork and communication during similar activities."),
            pw.Text("- Provide rewards for small achievements to boost motivation."),
            pw.Text("- Monitor time and focus to better understand the child’s progress."),
            pw.Text("- Consider consulting with a professional if NVLD traits are suspected."),
          ],
        ),
      ),
    );

    final pdfInMemory = await pdf.save();
    await _openPDFFromMemory(pdfInMemory);
  }

  Future<void> _openPDFFromMemory(Uint8List pdfInMemory) async {
    final pdfFile = await _createFileFromBytes(pdfInMemory);
    // Use a PDF viewer package like 'flutter_pdfview' to display the PDF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFView(
          filePath: pdfFile.path,
        ),
      ),
    );
  }

  Future<File> _createFileFromBytes(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/vocabulary_results.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<String> _fetchNVLDAdvice(int score, int timeTaken, int difficulty) async {
    try {
      final response = await http.post(
        Uri.parse(ENVConfig.serverUrl+'/get_nvld_advice'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "query": "summary of cognitive activity. Score: $score, Time Taken: $timeTaken, Difficulty: $difficulty",
          "score": score,
          "level": difficulty
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["advice"] ?? "No advice available at the moment.";
      } else {
        return "Failed to fetch advice.";
      }
    } catch (e) {
      return "Error fetching advice: $e";
    }
  }

  Future<void> updateIdentifyDifferenceScore(int predictedDifficulty) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('authEmployeeID');

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
      backgroundColor: Styles.fontHighlight2,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/1737431584894.png_image.png'), // Replace with your background image
            fit: BoxFit.cover, // Ensure the image covers the entire screen
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 5, left: 10, right: 10),
              child: AppBar(
                backgroundColor: Colors.transparent, // Transparent background
                elevation: 0, // Remove shadow
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identify Difference - Results',
                      style: TextStyle(
                        fontSize: 20, // Main title font size
                        color: Colors.black, // Text color
                      ),
                    ),
                    SizedBox(height: 4), // Space between title and subtitle
                    Text(
                      'Difficulty Level ${widget.difficulty}',
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
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: Color(0xff80ca84), // Background color for the circle
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
                    icon: Icon(Icons.arrow_back, color: Colors.white), // Back icon
                    onPressed: () {
                      Navigator.pop(context); // Navigate back
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Color(0xff80ca84), // Background color for the circle
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
                      icon: Icon(Icons.logout, color: Colors.white), // Logout icon
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: widget.assisted ? Colors.orange : Styles.fontHighlight,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.assisted
                          ? "Assisted Mode"
                          : widget.score >= 95
                          ? "Masterful Work!"
                          : widget.score >= 75
                          ? "Excellent Performance!"
                          : widget.score >= 60
                          ? "Great Job!"
                          : widget.score >= 30
                          ? "Good Effort!"
                          : "Keep Trying!",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      widget.assisted
                          ? "You completed the puzzle with assistance. Try challenging yourself next time!"
                          : widget.score >= 95
                          ? "Incredible precision and speed! You're a true master of this game."
                          : widget.score >= 75
                          ? "Fantastic performance! You’re honing your skills perfectly."
                          : widget.score >= 60
                          ? "Great work! Keep practicing for even better results."
                          : widget.score >= 30
                          ? "Good effort! You’re improving with each try."
                          : "Don’t give up! Every attempt gets you closer to success.",
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 10,),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Score: ${widget.score}%',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'Time Taken: ${formatTime(widget.timeTaken)}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Steps Taken: ${widget.moves}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Difficulty Level: ${widget.difficulty}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Assisted: ${widget.assisted ? "Yes" : "No"}',
                            style: TextStyle(
                              fontSize: 20,
                              color: widget.assisted ? Colors.yellow.shade200 : Colors.green.shade200,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),

                    ElevatedButton.icon(
                      onPressed: _generateAndShowPDF,
                      icon: const Icon(Icons.lightbulb),
                      label: const Text("Generate Report"),
                    ),
                  ],
                ),
              ),
            ),

            // Spacer between cards and details
            const SizedBox(height: 5,),


            // Feedback card at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Color(0xff80ca84),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Share Your Feedback',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedbackScreen(
                                  score: widget.score,
                                  category: 'difference find',
                                  difficulty: widget.difficulty,
                                  timeTaken: widget.timeTaken,
                                  moves: widget.moves,
                                  madeBy: '',
                                  user: 'SampleUser'),
                            ),
                          );

                        },
                        child: const Text('Give Feedback'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
    );
  }
}
