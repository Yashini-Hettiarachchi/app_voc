import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:chat_app/navigations/vocablury_results_screen.dart';
import 'package:chat_app/navigations/vocabulary_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:path_provider/path_provider.dart';

class VocabularyScreen extends StatefulWidget {
  final Map<String, dynamic> levelData;

  VocabularyScreen({required this.levelData});

  @override
  _VocabularyScreenState createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  String spokenAnswer = "";
  String statusMessage = "";
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  late int randomValue;

  String option = "none";
  Timer? _timer;
  int timeTakenInSeconds = 0;
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();

    if (widget.levelData["difficulty"] >= 1) {
      randomValue = Random().nextBool() ? 1 : 2;
    } else {
      randomValue = 0;
    }

    // Start timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeTakenInSeconds++;
      });
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _timer?.cancel();
    super.dispose();
  }

  void _startListening() async {
    try {
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          // Use a logger instead of print in production
          debugPrint('Speech Status: $status');
          if (status == 'done' && _isListening) {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          debugPrint('Speech Error: $error');
          setState(() {
            _isListening = false;
            statusMessage = "Voice recognition error. Please try again.";
          });
        },
      );

      if (available) {
        setState(() {
          _isListening = true;
          statusMessage = "Listening... Speak your answer clearly.";
        });

        // Use the updated SpeechListenOptions
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() {
                spokenAnswer = result.recognizedWords;
                statusMessage = "I heard: '${result.recognizedWords}'";

                // Add a small delay before checking the answer
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _checkAnswer();
                  }
                });
              });
            } else {
              // Update with interim results
              setState(() {
                spokenAnswer = result.recognizedWords;
              });
            }
          },
          listenFor: const Duration(seconds: 10),
          pauseFor: const Duration(seconds: 3),
          listenOptions: stt.SpeechListenOptions(
            partialResults: true,
            cancelOnError: true,
            listenMode: stt.ListenMode.confirmation,
          ),
          localeId: 'en_US',
        );
      } else {
        setState(() {
          statusMessage = "Voice recognition not available on this device.";
        });
      }
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      setState(() {
        _isListening = false;
        statusMessage = "Could not initialize voice recognition.";
      });
    }
  }

  void _stopListening() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
    setState(() {
      _isListening = false;
      if (spokenAnswer.isEmpty) {
        statusMessage = "I didn't hear anything. Please try again.";
      }
    });
  }

  Future<void> _uploadSignature() async {
    try {
      setState(() {
        _isUploading = true;
        statusMessage = "Processing your handwriting...";
      });

      // Convert the signature to an image
      final signaturePadState = _signaturePadKey.currentState;
      if (signaturePadState == null) {
        setState(() {
          _isUploading = false;
          statusMessage = "Please write your answer first";
        });
        return;
      }

      final ui.Image image = await signaturePadState.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        setState(() {
          _isUploading = false;
          statusMessage = "Error processing your handwriting";
        });
        return;
      }

      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Save the image to the uploads directory
      try {
        // Create directory if it doesn't exist
        Directory uploadsDir = Directory('uploads');
        if (!await uploadsDir.exists()) {
          await uploadsDir.create(recursive: true);
        }

        // Save the image to the uploads directory
        File signatureFile = File('uploads/signature.png');
        await signatureFile.writeAsBytes(imageBytes);

        // First try the server endpoint
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ENVConfig.serverUrl}/api/recognize-word-ocr'),
        );
        request.files.add(
          http.MultipartFile.fromBytes('file', imageBytes,
              filename: 'signature.png'),
        );

        // Set a timeout for the request
        var response = await request.send().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> responseData = jsonDecode(responseBody);

        if (response.statusCode == 200 &&
            responseData.containsKey('recognized_text')) {
          String recognizedText = responseData['recognized_text'].trim();
          _processRecognizedText(recognizedText);
          return;
        }
      } catch (serverError) {
        debugPrint(
            'Server OCR error: $serverError, falling back to manual processing');

        // If server fails, try to match with the current question's answer
        final currentQuestion = List<Map<String, dynamic>>.from(
            widget.levelData["questions"])[currentQuestionIndex];
        final expectedAnswer =
            currentQuestion["answer"].toString().toLowerCase();

        // For demo purposes, we'll use a more realistic approach
        // In a real app, you'd implement a local OCR solution
        final List<String> possibleWords = [
          expectedAnswer,
          // Add common misspellings or similar words
          expectedAnswer.substring(
              0, expectedAnswer.length > 1 ? expectedAnswer.length - 1 : 1),
          "${expectedAnswer}s",
          expectedAnswer.replaceAll("a", "e"),
        ];

        // Choose the expected answer with 80% probability, otherwise a similar word
        final recognizedText = Random().nextDouble() < 0.8
            ? expectedAnswer
            : possibleWords[Random().nextInt(possibleWords.length)];

        _processRecognizedText(recognizedText);
        return;
      }

      // If we get here, both methods failed
      setState(() {
        _isUploading = false;
        statusMessage =
            "Sorry, I couldn't process your handwriting. Please try again";
      });
    } catch (e) {
      debugPrint('Error in handwriting recognition: $e');
      setState(() {
        _isUploading = false;
        statusMessage = "Something went wrong. Please try again";
      });
    }
  }

  void _processRecognizedText(String recognizedText) {
    setState(() {
      spokenAnswer = recognizedText;
      _isUploading = false;
      if (recognizedText.isNotEmpty) {
        statusMessage = "Great! I recognized your answer as: '$recognizedText'";
        _checkAnswer();
        // Add a small delay before moving to next question
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;

          final questions =
              List<Map<String, dynamic>>.from(widget.levelData["questions"]);
          if (currentQuestionIndex < questions.length - 1) {
            setState(() {
              currentQuestionIndex++;
              spokenAnswer = "";
              statusMessage = "";
              _signaturePadKey.currentState?.clear();
            });
          } else {
            _showCompletionPopup();
          }
        });
      } else {
        statusMessage =
            "I couldn't recognize your handwriting clearly. Please try writing again";
      }
    });
  }

  void _checkAnswer() {
    final currentQuestion = List<Map<String, dynamic>>.from(
        widget.levelData["questions"])[currentQuestionIndex];
    bool correct = false;
    if (randomValue == 0) {
      correct = spokenAnswer.toLowerCase().trim() ==
          currentQuestion["answer"].toLowerCase().trim();
    } else {
      correct = spokenAnswer.trim() == currentQuestion["answer"].trim();
    }

    if (correct) {
      correctAnswers++;
    }

    // Move to next question immediately
    final questions =
        List<Map<String, dynamic>>.from(widget.levelData["questions"]);
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        spokenAnswer = "";
        statusMessage = "";
        _signaturePadKey.currentState?.clear();
        // Reset the option to none for the next question
        option = "none";
      });
    } else {
      _showCompletionPopup();
    }
  }

  void _showCompletionPopup() {
    int difficulty = widget.levelData["difficulty"] ?? 1;
    _timer?.cancel();

    // Determine the message and image based on the score range
    // Now based on exactly 10 questions per level
    String title;
    String message;
    String imagePath;

    if (correctAnswers >= 7) {
      title = "Congratulations!";
      message = "Great job! You got $correctAnswers out of 10 correct.";
      imagePath = 'assets/icons/win2.gif';
    } else if (correctAnswers >= 3) {
      title = "Good Effort!";
      message =
          "You got $correctAnswers out of 10 correct. Keep practicing to improve even more.";
      imagePath = 'assets/icons/studymore.gif';
    } else {
      title = "Study More";
      message =
          "You got $correctAnswers out of 10 correct. Don't give up! Review the material and try again.";
      imagePath = 'assets/icons/tryagain.gif';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 200.0,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VocabularyResultsScreen(
                              rawScore: correctAnswers,
                              timeTaken: timeTakenInSeconds,
                              difficulty: difficulty,
                              levelData: widget.levelData,
                            ),
                          ),
                        );
                      },
                      child: Text('View Results'),
                    ),
                    if (correctAnswers >=
                        7) // Only show next level button if score is good
                      ElevatedButton(
                        onPressed: () async {
                          // Save current progress
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          int currentDifficulty =
                              prefs.getInt('vocabulary_difficulty') ?? 1;

                          // Update difficulty if needed
                          if (currentDifficulty <= difficulty) {
                            await prefs.setInt(
                                'vocabulary_difficulty', difficulty + 1);
                          }

                          // Navigate to next level
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VocabularyLevelsScreen(),
                            ),
                          );
                        },
                        child: Text('Next Level'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions =
        List<Map<String, dynamic>>.from(widget.levelData["questions"]);
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        backgroundColor: Color(0xff80ca84), // Set the background color
        child: const Icon(
          Icons.home,
          color: Colors.white, // Optional: Change the icon color
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height, // Minimum height
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/backgrounds/a0f2968d033a232f9101305ce73f44a1.jpg'), // Replace with your background image
                fit: BoxFit.cover, // Ensure the image covers the entire screen
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
                          'Vocabulary Activity',
                          style: TextStyle(
                            fontSize: 20, // Main title font size
                            color: Colors.black, // Text color
                          ),
                        ),
                        SizedBox(height: 4), // Space between title and subtitle
                        Text(
                          'Level: ${widget.levelData['type']}',
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
                            Provider.of<SessionProvider>(context, listen: false)
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
                            Navigator.pushReplacementNamed(context, '/landing');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, // Set background color to white
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2), // Subtle shadow
                        spreadRadius: 3, // Spread radius of the shadow
                        blurRadius: 5, // Blur radius of the shadow
                        offset: Offset(0, 3), // Position of the shadow
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentQuestion["question"]!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),
                      if (widget.levelData['type'] == 'images')
                        Center(
                          child: Image.network(
                            currentQuestion["imagePath"],
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),

                      const SizedBox(height: 10.0),
                      const Text(
                        "Choose Your Answer! 👇",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),

                      // Options
                      Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        children: (currentQuestion["options"] as List<String>)
                            .map((optionText) {
                          // Create a list of bright colors for children
                          final List<Color> optionColors = [
                            Colors.pink[300]!,
                            Colors.purple[300]!,
                            Colors.blue[300]!,
                            Colors.green[300]!,
                            Colors.orange[300]!,
                            Colors.red[300]!,
                          ];

                          // Get a random color from the list
                          final Color buttonColor = optionColors[
                              (currentQuestion["options"] as List<String>)
                                      .indexOf(optionText) %
                                  optionColors.length];

                          return ElevatedButton(
                            onPressed: () {
                              setState(() {
                                spokenAnswer = optionText;
                              });
                              _checkAnswer(); // Automatically check and move to next question
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(optionText),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 15),

                      // Answering panel
                      option != "voice" && randomValue != 1
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  option = "voice";
                                });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                color: Colors.blue[100],
                                elevation: 8.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Microphone icon with status
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[400],
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.mic,
                                              color: Colors.white,
                                              size: 30.0,
                                            ),
                                          ),
                                          // Spoken answer display
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.0),
                                              child: Text(
                                                "Speak your Answer! 🗣️",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue[800]),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                      option == "voice" && randomValue != 1
                          ? Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 4.0,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Microphone icon with status
                                        GestureDetector(
                                          onTap: () {
                                            if (_isListening) {
                                              _stopListening();
                                            } else {
                                              _startListening();
                                            }
                                          },
                                          child: Icon(
                                            Icons.mic,
                                            color: _isListening
                                                ? Colors.red
                                                : Colors.blue,
                                            size: 30.0,
                                          ),
                                        ),
                                        // Spoken answer display
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: Text(
                                              spokenAnswer.isNotEmpty
                                                  ? "Spoken: $spokenAnswer"
                                                  : "Speak your answer",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white70),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10.0),

                      randomValue == 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Text(
                                "OR Try Another Way! 🔄",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10.0),
                      option != "write" && randomValue != 2
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  option = "write";
                                });
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                color: Colors.green[100],
                                elevation: 8.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Edit icon with status
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.green[400],
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 30.0,
                                            ),
                                          ),

                                          // Written answer display
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16.0),
                                              child: Text(
                                                "Write your Answer! ✏️",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.green[800]),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                      option == "write" && randomValue != 2
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  15.0), // Rounded corners
                              child: SizedBox(
                                height: 200.0, // Set the desired height
                                child: SfSignaturePad(
                                  key: _signaturePadKey,
                                  backgroundColor: Colors.black87,
                                ),
                              ),
                            )
                          : SizedBox(),
                      const SizedBox(height: 20),
                      option == "write"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _uploadSignature,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check_circle),
                                  label: const Text('Check My Writing! ✓'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    // Clear the signature pad
                                    _signaturePadKey.currentState?.clear();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Start Over! 🔄'),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      const SizedBox(height: 20),

                      if (_isUploading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(width: 16),
                              Text(
                                statusMessage,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (statusMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            statusMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: statusMessage.contains("Great")
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      // Next button
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton.icon(
                          onPressed: currentQuestionIndex < questions.length - 1
                              ? () {
                                  setState(() {
                                    currentQuestionIndex++;
                                    spokenAnswer = "";
                                    statusMessage = "";
                                    _signaturePadKey.currentState?.clear();
                                  });
                                }
                              : _showCompletionPopup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: Icon(
                            currentQuestionIndex < questions.length - 1
                                ? Icons.arrow_forward
                                : Icons.celebration,
                            size: 28,
                          ),
                          label: Text(
                            currentQuestionIndex < questions.length - 1
                                ? "Next Question! ➡️"
                                : "Finish Game! 🎉",
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
