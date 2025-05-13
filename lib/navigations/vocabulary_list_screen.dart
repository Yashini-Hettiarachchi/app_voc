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
      debugPrint("Audio Init");
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0); // Set pitch
      await flutterTts.setSpeechRate(0.5); // Set a moderate speech rate
      await flutterTts
          .awaitSpeakCompletion(true); // Ensure it waits for completion
      await flutterTts.speak(instruction); // Speak the provided text
    } catch (e) {
      debugPrint("Error during TTS operation: $e");
    }
  }

  void _showInteractiveTutorial() {
    // Show a step-by-step tutorial for first-time users
    final List<Map<String, dynamic>> tutorialSteps = [
      {
        "title": "Welcome to Vocabulary Adventure! 👋",
        "content":
            "This tutorial will guide you through how to use the vocabulary learning activities.",
        "image": Icons.school,
      },
      {
        "title": "Choosing Levels 🎮",
        "content":
            "Tap on any unlocked level card to start playing. Locked levels will be available as you improve!",
        "image": Icons.lock_open,
      },
      {
        "title": "Multiple Ways to Answer ✏️",
        "content":
            "You can answer questions by selecting options, speaking, or writing your answer.",
        "image": Icons.mic,
      },
      {
        "title": "Track Your Progress 📊",
        "content":
            "Check your previous records to see how you're improving over time.",
        "image": Icons.bar_chart,
      },
      {
        "title": "Ready to Start? 🚀",
        "content": "Let's begin your vocabulary adventure!",
        "image": Icons.play_circle_filled,
      },
    ];

    int currentStep = 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(
                    tutorialSteps[currentStep]["image"],
                    color: Colors.purple,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tutorialSteps[currentStep]["title"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                height: 150,
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tutorialSteps[currentStep]["content"],
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      value: (currentStep + 1) / tutorialSteps.length,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Step ${currentStep + 1} of ${tutorialSteps.length}",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (currentStep > 0)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentStep--;
                      });
                    },
                    child: const Text("Previous"),
                  ),
                TextButton(
                  onPressed: () {
                    if (currentStep < tutorialSteps.length - 1) {
                      setState(() {
                        currentStep++;
                      });
                    } else {
                      // Save that tutorial has been shown
                      SharedPreferences.getInstance().then((prefs) {
                        prefs.setBool('tutorial_shown', true);
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(
                    currentStep < tutorialSteps.length - 1 ? "Next" : "Finish",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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

    // Check if we should show the tutorial
    _checkAndShowTutorial();
  }

  Future<void> _checkAndShowTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool tutorialShown = prefs.getBool('tutorial_shown') ?? false;

    if (!tutorialShown && mounted) {
      // Delay showing the tutorial to allow the screen to build
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showInteractiveTutorial();
        }
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getPrediction(int grade, int timeTaken) async {
    try {
      print('Calling prediction API with grade=$grade, time_taken=$timeTaken');

      // First try the external API
      try {
        final response = await http
            .get(
              Uri.parse(
                  'https://yasiruperera.pythonanywhere.com/predict?grade=$grade&time_taken=$timeTaken'),
            )
            .timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('External API Response: $data');
          // Ensure we have the expected fields in the response
          return {
            'original_grade': data['input_data']['original_grade'] ?? grade,
            'adjusted_grade': data['adjusted_grade'] ?? grade,
            'adjustment': data['adjustment'] ?? 0,
            'status': data['status'] ?? 'unknown'
          };
        } else {
          print(
              'External API Error: ${response.statusCode} - ${response.body}');
          throw Exception('Failed to get prediction from external API');
        }
      } catch (externalApiError) {
        print(
            'Error with external API: $externalApiError, falling back to local API');

        // Fall back to local API if external fails
        try {
          final localResponse = await http
              .get(
                Uri.parse(
                    '${ENVConfig.serverUrl}/predict?grade=$grade&time_taken=$timeTaken'),
              )
              .timeout(const Duration(seconds: 3));

          if (localResponse.statusCode == 200) {
            final data = jsonDecode(localResponse.body);
            print('Local API Response: $data');
            return {
              'original_grade': data['input_data']['original_grade'] ?? grade,
              'adjusted_grade': data['adjusted_grade'] ?? grade,
              'adjustment': data['adjustment'] ?? 0,
              'status': data['status'] ?? 'success'
            };
          } else {
            throw Exception('Failed to get prediction from local API');
          }
        } catch (localApiError) {
          print('Error with local API: $localApiError, using fallback logic');

          // If both APIs fail, use fallback logic
          int adjustedGrade = grade;
          int adjustment = 0;

          // For grade > 1, tend to decrease (matching observed API behavior)
          if (grade > 1) {
            adjustment = -1;
            adjustedGrade = grade - 1;
          }

          return {
            'original_grade': grade,
            'adjusted_grade': adjustedGrade,
            'adjustment': adjustment,
            'status': 'success'
          };
        }
      }
    } catch (e) {
      print('Error in prediction logic: $e');
      return {
        'original_grade': grade,
        'adjusted_grade': grade,
        'adjustment': 0,
        'status': 'error'
      };
    }
  }

  void _navigateToVocabularyScreen(Map<String, dynamic> levelData) async {
    // Get current difficulty level from the level data
    final levelDifficulty = levelData['difficulty'] ?? 1;

    // Get the current user's difficulty level from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final currentDifficulty = prefs.getInt('vocabulary_difficulty') ?? 1;
    final lastTimeTaken = prefs.getInt('last_time_taken') ?? 800;

    // Get prediction for level adjustment using actual performance data
    try {
      // Use the prediction API to determine if the level should be accessible
      final prediction = await _getPrediction(currentDifficulty, lastTimeTaken);
      final adjustedGrade = prediction['adjusted_grade'];

      // Log the prediction results for debugging
      debugPrint(
          'Level difficulty: $levelDifficulty, User difficulty: $currentDifficulty');
      debugPrint('API prediction: $prediction');
      debugPrint('Adjusted grade: $adjustedGrade');

      // Store the adjusted grade in SharedPreferences
      await prefs.setInt('vocabulary_difficulty', adjustedGrade);

      // Update the levelsToShow based on adjusted grade
      if (mounted) {
        setState(() {
          levelsToShow = adjustedGrade;
        });
      }

      // Check if the level should be accessible
      // A level is locked if its difficulty is greater than the user's adjusted grade
      if (levelDifficulty > adjustedGrade) {
        // Show dialog if level is locked with more detailed information
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Level Locked 🔒',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  const Text(
                    'You need to complete previous levels first.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current recommended level: ${_getGrade(adjustedGrade)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete earlier levels with better scores and faster times to unlock this level!',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          );
        }
        return;
      }
    } catch (e) {
      debugPrint('Error getting prediction: $e');
      // Continue with default behavior if API fails

      // If API fails, use a simple check based on stored difficulty
      if (levelDifficulty > currentDifficulty && mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Level Locked 🔒'),
            content: const Text(
                'Complete previous levels first to unlock this level.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // If level is accessible or API call failed, proceed with quiz
    final questions = List<Map<String, dynamic>>.from(levelData['questions']);

    // Use a more robust randomization with a seed based on current time
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    questions.shuffle(random);

    // Ensure we have exactly 10 questions per level
    if (questions.length < 10) {
      print(
          'Warning: Level ${levelData['title']} has fewer than 10 questions (${questions.length})');
      // If there are fewer than 10 questions, duplicate some to reach 10
      while (questions.length < 10) {
        // Add duplicates of existing questions with slight modifications
        final questionToDuplicate =
            questions[questions.length % questions.length];
        final duplicatedQuestion =
            Map<String, dynamic>.from(questionToDuplicate);
        questions.add(duplicatedQuestion);
      }
    }

    // Take exactly 10 questions
    final limitedQuestions = questions.take(10).toList();

    print(
        'Selected ${limitedQuestions.length} random questions for level ${levelData['title']}');

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
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                    icon: const Icon(Icons.menu_book),
                                    label: const Text("Instructions PDF"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[700],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _playInstructions();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Playing audio instructions...'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.volume_up),
                                    label: const Text("Audio Instructions"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[700],
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 36),
                                ),
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
                          future: () async {
                            // Get the current difficulty and last time taken from SharedPreferences
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            final currentGrade =
                                prefs.getInt('vocabulary_difficulty') ?? 1;
                            final lastTimeTaken =
                                prefs.getInt('last_time_taken') ?? 800;

                            // Call the prediction API with dynamic values
                            try {
                              return await _getPrediction(
                                  currentGrade, lastTimeTaken);
                            } catch (e) {
                              debugPrint('Error in FutureBuilder: $e');
                              // Return a fallback prediction if API call fails
                              return {
                                'original_grade': currentGrade,
                                'adjusted_grade': currentGrade,
                                'adjustment': 0,
                                'status': 'error'
                              };
                            }
                          }(),
                          builder: (context, snapshot) {
                            bool isLocked = false;

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              // While waiting for the API response, use the current grade from SharedPreferences
                              isLocked = (level["difficulty"] ?? 1) > _diff;
                            } else if (snapshot.hasData) {
                              final adjustedGrade =
                                  snapshot.data!['adjusted_grade'];
                              // Lock levels that are higher than the adjusted grade from the prediction API
                              isLocked =
                                  (level["difficulty"] ?? 1) > adjustedGrade;

                              // Debug log
                              debugPrint(
                                  'Level ${level["title"]} (difficulty: ${level["difficulty"]}): ${isLocked ? "LOCKED" : "UNLOCKED"}');
                            } else if (snapshot.hasError) {
                              // If there's an error, fall back to the current grade
                              debugPrint(
                                  'Error in FutureBuilder: ${snapshot.error}');
                              isLocked = (level["difficulty"] ?? 1) > _diff;
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
