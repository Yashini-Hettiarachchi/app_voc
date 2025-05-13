import 'dart:io';
import 'dart:math';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:chat_app/navigations/image_test_screen.dart';
import 'package:chat_app/navigations/previous_vocabulary_records_screen.dart';
import 'package:chat_app/navigations/vocabulary_screen.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'dart:convert';

class VocabularyLevelsScreen extends StatefulWidget {
  @override
  _VocabularyLevelsScreenState createState() => _VocabularyLevelsScreenState();
}

class _VocabularyLevelsScreenState extends State<VocabularyLevelsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _diff = 1;
  int levelsToShow = 1;
  final FlutterTts flutterTts = FlutterTts();

  // Sample data for vocabulary levels from the PDF content
  final List<Map<String, dynamic>> levels = ENVConfig.levels;

  void _playInstructions() async {
    String instruction =
        "In this vocabulary activity, players will progress through multiple levels, each offering a range of difficulties, including Basic, Normal, Hard, Very Hard, and Challenging. Participants can engage with various question formats, including voice-based responses and signature pad input for written answers. Additionally, image-based activities require players to identify the correct name of an object from a selection of images. As the difficulty increases, words become more complex, testing both recognition and recall skills. Complete each challenge accurately to advance to the next level and improve your vocabulary proficiency!";
    try {
      print("Audio Init");
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0); // Set pitch
      await flutterTts.setSpeechRate(0.5); // Set a moderate speech rate
      await flutterTts
          .awaitSpeakCompletion(true); // Ensure it waits for completion
      await flutterTts.speak(instruction); // Speak the provided text
    } catch (e) {
      print("Error during TTS operation: $e");
    }
  }

  Future<void> _loadDifficulty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? d = prefs.getInt('vocabulary_difficulty');

    setState(() {
      _diff = d ?? 1;
      levelsToShow = d ?? 1;
      // if (levelsToShow > levels.length) {
      //   // If not enough levels for the selected difficulty, show available levels + dummy level
      //   levelsToShow = levels.length;
      // }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDifficulty();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getPrediction(int grade, int timeTaken) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://yasiruperera.pythonanywhere.com/predict?grade=$grade&time_taken=$timeTaken'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Ensure we have the expected fields in the response
        return {
          'original_grade': data['input_data']['original_grade'] ?? grade,
          'adjusted_grade': data['adjusted_grade'] ?? grade,
          'adjustment': data['adjustment'] ?? 0,
          'status': data['status'] ?? 'unknown'
        };
      } else {
        throw Exception('Failed to get prediction');
      }
    } catch (e) {
      print('Error getting prediction: $e');
      return {
        'original_grade': grade,
        'adjusted_grade': grade,
        'adjustment': 0,
        'status': 'error'
      };
    }
  }

  void _navigateToVocabularyScreen(Map<String, dynamic> levelData) async {
    // Get current difficulty level
    final currentDifficulty = levelData['difficulty'] ?? 1;

    // Get prediction for level adjustment
    try {
      // Use the prediction API to determine if the level should be accessible
      final prediction = await _getPrediction(currentDifficulty, 800);
      final adjustedGrade = prediction['adjusted_grade'];

      // Store the adjusted grade in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('vocabulary_difficulty', adjustedGrade);

      // Update the levelsToShow based on adjusted grade
      if (mounted) {
        setState(() {
          levelsToShow = adjustedGrade;
        });
      }

      // Check if the level should be accessible
      if (levelData['difficulty'] > adjustedGrade) {
        // Show dialog if level is locked
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Level Locked'),
              content: Text(
                  'You need to complete previous levels first. Current recommended level: $adjustedGrade'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }
    } catch (e) {
      print('Error getting prediction: $e');
      // Continue with default behavior if API fails
    }

    // If level is accessible or API call failed, proceed with quiz
    final questions = List<Map<String, dynamic>>.from(levelData['questions']);
    questions.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
    final limitedQuestions = questions.take(10).toList();

    final updatedLevelData = {
      ...levelData,
      'questions': limitedQuestions,
    };

    // Check if widget is still mounted before navigating
    if (!mounted) return;

    if (levelData["type"] == "image") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageTestScreen(levelData: updatedLevelData),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VocabularyScreen(levelData: updatedLevelData),
        ),
      );
    }
  }

  Future<File> _loadPDFfromAssets(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File("${tempDir.path}/document.pdf");
    await tempFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return tempFile;
  }

  String _getGrade(int difficulty) {
    switch (difficulty) {
      case 0:
        return "Initial";
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

  IconData _getLevelIcon(String type) {
    switch (type) {
      case "image":
        return Icons.image;
      default:
        return Icons.text_fields;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the UI

    return Scaffold(
      body: Stack(
        children: [
          Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/backgrounds/1737431584894.png_image.png'), // Replace with your background image
                  fit:
                      BoxFit.cover, // Ensure the image covers the entire screen
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                    child: AppBar(
                      backgroundColor:
                          Colors.transparent, // Transparent background
                      elevation: 0, // Remove shadow
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Word Recognition',
                            style: TextStyle(
                              fontSize: 20, // Main title font size
                              color: Colors.black, // Text color
                            ),
                          ),
                          SizedBox(
                              height: 4), // Space between title and subtitle
                          Text(
                            'Grade ${_getGrade(_diff)}',
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
                          color: Color(
                              0xff80ca84), // Background color for the circle
                          shape: BoxShape.circle, // Circular shape
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orangeAccent
                                  .withOpacity(0.6), // Glow effect
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: Colors.white), // Back icon
                          onPressed: () {
                            Navigator.pop(context); // Navigate back
                          },
                        ),
                      ),
                      actions: [
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Color(
                                0xff80ca84), // Background color for the circle
                            shape: BoxShape.circle, // Circular shape
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orangeAccent
                                    .withOpacity(0.6), // Glow effect
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.logout,
                                color: Colors.white), // Logout icon
                            onPressed: () async {
                              Provider.of<SessionProvider>(context,
                                      listen: false)
                                  .clearSession();
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

                              // Check if widget is still mounted before navigating
                              if (mounted) {
                                Navigator.pushReplacementNamed(
                                    context, '/landing');
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
                      height: 200,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xff27a5c6),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                "Word Adventure! 🎮",
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.emoji_events,
                                color: Colors.yellow,
                                size: 30,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12.0),
                          const Text(
                            "Pick a fun level to play and learn new words! 🚀",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly, // Space out buttons evenly
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  File pdfFile = await _loadPDFfromAssets(
                                      "assets/instructions/vocabulary booklet.pdf");

                                  // Check if widget is still mounted before navigating
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PDFView(
                                          filePath: pdfFile.path,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.voice_chat),
                                label: const Text("Instructions"),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            PreviousVocabularyRecordsScreen()),
                                  );
                                },
                                icon: const Icon(Icons.history),
                                label: const Text("Previous Records"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // List view of vocabulary levels
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];

                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getPrediction(3,
                              800), // Use grade=3 and time_taken=800 as specified in the URL
                          builder: (context, snapshot) {
                            bool isLocked = false;
                            if (snapshot.hasData) {
                              final adjustedGrade =
                                  snapshot.data!['adjusted_grade'];
                              // Lock levels that are higher than the adjusted grade from the prediction API
                              isLocked =
                                  (level["difficulty"] ?? 1) > adjustedGrade;
                            }

                            return GestureDetector(
                              onTap: () {
                                _navigateToVocabularyScreen(level);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: level["color"],
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 2),
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Level content
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Level icon or image
                                          Icon(
                                            _getLevelIcon(level["type"]),
                                            size: 48.0,
                                            color: Colors.white,
                                          ),
                                          SizedBox(height: 12.0),
                                          // Level title
                                          Text(
                                            level["title"],
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 8.0),
                                          // Level description
                                          Text(
                                            level["description"],
                                            style: TextStyle(
                                              fontSize: 12.0,
                                              color: Colors.white70,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Lock overlay
                                    if (isLocked)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red[400],
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.lock,
                                                      color: Colors.white,
                                                      size: 40.0,
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 80,
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.yellow,
                                                        width: 3,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12.0),
                                              const Text(
                                                'Level Locked! 🔒',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Complete previous level first!',
                                                style: const TextStyle(
                                                  color: Colors.yellow,
                                                  fontSize: 14.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff80ca84),
        onPressed: () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          }
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
