import 'dart:convert';
// import 'dart:ffi';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/difference_find_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:chat_app/navigations/difference_levels_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DifferenceFindScreen extends StatefulWidget {
  final Map<String, dynamic> levelData;
  final int difficulty;

  const DifferenceFindScreen({
    required this.levelData,
    required this.difficulty,
  });

  @override
  _DifferenceFindScreenState createState() => _DifferenceFindScreenState();
}

class _DifferenceFindScreenState extends State<DifferenceFindScreen> {
  GlobalKey _repaintBoundaryKey = GlobalKey();
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<Offset> draggablePositions = [];
  final List<Offset> staticPositions = [];
  late int missingObjectIndex;
  late int secondMissingObjectIndex;
  Set<int> correctlyIdentifiedObjects = {};
  bool isCorrect = false;
  bool showHighlight = false;
  bool isLoading = true;
  Uint8List? generatedImage;
  Uint8List? orginal;
  int total = 0;

  late Stopwatch stopwatch;
  int dragMoves = 0;

  @override
  void initState() {
    super.initState();
    _generateImageFromPrompt();

    final random = Random();

    for (int i = 0; i < widget.levelData["objects"].length; i++) {
      draggablePositions.add(
        Offset(
          random.nextDouble() * 200 + 50,
          random.nextDouble() * 150 + 50,
        ),
      );
    }

    // Randomly choose two objects to be missing in the static section
    missingObjectIndex = random.nextInt(widget.levelData["objects"].length);
    secondMissingObjectIndex = random
        .nextInt(widget.levelData["objects"].length - 1); // Ensure different indices
    if (secondMissingObjectIndex >= missingObjectIndex) {
      secondMissingObjectIndex++;
    }

    for (int i = 0; i < widget.levelData["objects"].length; i++) {
      if (i != missingObjectIndex && i != secondMissingObjectIndex) {
        staticPositions.add(
          Offset(
            random.nextDouble() * 200 + 50,
            random.nextDouble() * 150 + 300,
          ),
        );
      }
    }

    stopwatch = Stopwatch()..start();
  }

  Future<void> _generateImageFromPrompt() async {
    const apiKey =
        'DEZGO-E3892C6F00D69E6884C9A7F907306607D71183DD810B9DA21363DA510F818EFFA4E31415';
    const url = 'https://api.dezgo.com/text2image';

    final payload = {
      "prompt": widget.levelData['hint'] ??
          "A simple indoor scene illustrating various object placements.",
      "steps": 10,
      "sampler": "euler_a",
      "scale": 7.5,
    };

    final headers = {
      'X-Dezgo-Key': apiKey,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        setState(() {
          generatedImage = response.bodyBytes;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _captureSnapshot() async {
    print("capturing");
    RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage(pixelRatio: 3.0); // Increase pixel ratio for better quality
    image.toByteData(format: ImageByteFormat.png).then((byteData) {
      setState(() {
        orginal = byteData!.buffer.asUint8List();
      });
    });
  }

  void _activateVoiceAssistance() {
    setState(() {
      showHighlight = true;
    });

    // Show a dialog for guidance (optional)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Voice Assistance",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "The missing object is now highlighted to help you find it!",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () => {

            },
            child: const Text(
              "Guide Me",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  void calculateScore() {
    final elapsedSeconds = stopwatch.elapsed.inSeconds;

    // Calculate score
    const int maxScore = 100;
    const int maxTimePenalty = 40; // Maximum penalty for time
    const int maxMovesPenalty = 30; // Maximum penalty for drag moves
    const int baseTimeThreshold = 60; // Time threshold for penalties
    const int baseMovesThreshold = 20; // Drag move threshold for penalties

    int timePenalty = (elapsedSeconds*0.2).toInt();

    double movesPenalty = ((dragMoves-2)*(2+ widget.difficulty)).toDouble();

    // Ensure penalties don't exceed their respective caps
    timePenalty = timePenalty.clamp(0, maxTimePenalty).toInt();
    // movesPenalty = movesPenalty.clamp(0, maxMovesPenalty) as double;


    int score = (maxScore - timePenalty.round()).toInt();

    // Cap score to 60 if highlight was used
    if (showHighlight) {
      score = score.clamp(0, 60);
    }

    score = (score - movesPenalty).clamp(0, 100).toInt();

    setState(() {
      total = score;
    });
  }


  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent the dialog from being dismissed by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero, // Remove default padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Optional: Rounded corners
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // GIF image at the top (full width)
              Container(
                width: double.infinity,
                height: 200.0, // Adjust the height based on your preference
                child: Image.asset(
                  'assets/icons/win3.gif', // Path to your correct GIF
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16.0), // Space between the GIF and text
              // "Congratulations" text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Congratulations!",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10), // Adds some space between the texts
                    Text(
                      "Tap 'Next' to view your results and learn more.",
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
              SizedBox(height: 16.0), // Space between text and button
              // "Next" button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DifferenceFindResultsScreen(
                          score: total,
                          moves: dragMoves,
                          difficulty: widget.difficulty,
                          timeTaken: stopwatch.elapsed.inSeconds,
                          assisted: showHighlight,
                        ),
                      ),
                    );
                    // Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Next'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStatsPopup() {
    final elapsedSeconds = stopwatch.elapsed.inSeconds;

    // Calculate score
    const int maxScore = 100;
    const int maxTimePenalty = 40; // Maximum penalty for time
    const int maxMovesPenalty = 30; // Maximum penalty for drag moves
    const int baseTimeThreshold = 60; // Time threshold for penalties
    const int baseMovesThreshold = 20; // Drag move threshold for penalties

    int timePenalty = (elapsedSeconds*0.2).toInt();

    double movesPenalty = ((dragMoves-2)*(2+ widget.difficulty)).toDouble();

    // Ensure penalties don't exceed their respective caps
    timePenalty = timePenalty.clamp(0, maxTimePenalty).toInt();
    // movesPenalty = movesPenalty.clamp(0, maxMovesPenalty) as double;


    int score = (maxScore - timePenalty.round()).toInt();

    // Cap score to 60 if highlight was used
    if (showHighlight) {
      score = score.clamp(0, 60);
    }

    score = (score - movesPenalty).clamp(0, 100).toInt();

    setState(() {
      total = score;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Game Stats", style: TextStyle(color: Colors.white70)),
        content: Text(
          "Time Taken: $elapsedSeconds seconds\n"
              "Drag Moves Made: $dragMoves\n"
              "Score: $score%",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                showHighlight = true;
              });
            },
            child: const Text(
              "Guide Me",
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.primaryAccent,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
                      widget.levelData["title"],
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

            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    // Background image
                    if (generatedImage != null)
                      Positioned.fill(
                        child: Image.memory(
                          generatedImage!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    // Draggable objects
                    for (int i = 0; i < widget.levelData["objects"].length; i++)
                      Positioned(
                        left: draggablePositions[i].dx,
                        top: draggablePositions[i].dy,
                        child: Draggable<int>(
                          data: i,
                          feedback: Stack(
                            children: [
                              if (showHighlight && i == missingObjectIndex)
                                Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.yellow.withOpacity(0.5),
                                  ),
                                ),
                              Image.asset(
                                widget.levelData["objects"][i],
                                width: 50.0,
                                height: 50.0,
                              ),
                            ],
                          ),
                          childWhenDragging: Container(),
                          child: Stack(
                            children: [
                              if (showHighlight && i == missingObjectIndex)
                                Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.yellow.withOpacity(0.5),
                                  ),
                                ),
                              Image.asset(
                                widget.levelData["objects"][i],
                                width: 50.0,
                                height: 50.0,
                              ),
                            ],
                          ),
                          onDragEnd: (details) {
                            if(dragMoves==0) {
                              _captureSnapshot();
                            }
                            setState(() {
                              dragMoves++;
                              audioPlayer.play(AssetSource('audios/normal.mp3'));
                              if ((i == missingObjectIndex || i == secondMissingObjectIndex) &&
                                  details.offset.dy > MediaQuery.of(context).size.height * 0.5) {
                                correctlyIdentifiedObjects.add(i);
                                draggablePositions[i] = Offset(
                                  details.offset.dx - 10,
                                  details.offset.dy - AppBar().preferredSize.height - 10,
                                );
                                audioPlayer.play(AssetSource('audios/success.mp3'));

                                if (correctlyIdentifiedObjects.contains(missingObjectIndex) &&
                                    correctlyIdentifiedObjects.contains(secondMissingObjectIndex)) {
                                  audioPlayer.play(AssetSource('audios/success.mp3'));
                                  isCorrect = true;
                                  stopwatch.stop();
                                  calculateScore();

                                  _showCongratulationsDialog();
                                }
                              } else {
                                draggablePositions[i] = Offset(
                                  details.offset.dx - 10,
                                  details.offset.dy - AppBar().preferredSize.height - 10,
                                );
                              }
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Elevated Button (10% width)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1, // 10% of screen width
                    height: MediaQuery.of(context).size.width * 0.1, // Optional: make it square for perfect centering
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3, // Slight elevation
                        backgroundColor: Color(0xff80ca84), // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded edges
                        ),
                        padding: EdgeInsets.zero, // Remove default padding for better centering
                      ),
                      onPressed: _showStatsPopup,
                      child: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 24, // Adjust the size of the icon if needed
                      ), // Information icon
                    ),
                  ),
                  SizedBox(width: 8), // Space between button and container
                  // Full-width Container
                  Expanded(
                    child: Container(
                      width: double.infinity, // Makes the container take the full width
                      margin: const EdgeInsets.symmetric(vertical: 16.0), // Optional for spacing
                      padding: const EdgeInsets.all(12.0), // Padding inside the box
                      decoration: BoxDecoration(
                        color: Color(0xff27a5c6), // Transparent background
                        border: Border.all(
                          color: Colors.white, // White border
                          width: 2.0,
                          style: BorderStyle.solid, // Border style
                        ),
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners (optional)
                      ),
                      child: Center(
                        child: Text(
                          isCorrect ? "CORRECT" : "DROP HERE",
                          style: TextStyle(
                            color: isCorrect ? Colors.white : Colors.white60,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center, // Center the text
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (orginal != null)
              Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      Image.memory(orginal!),
                    ],
                  )
              ),
            if (orginal == null) Expanded(
              flex: 4,
              child: Padding(padding: EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                children: [
                  RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Stack(
                      children: [
                        if (generatedImage != null)
                          Positioned.fill(
                            child: Image.memory(
                              generatedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        // Static objects at fixed positions, excluding the missing object
                        for (int i = 0; i < widget.levelData["objects"].length; i++)
                          if (i != missingObjectIndex&&i != secondMissingObjectIndex)
                            Positioned(
                              left: draggablePositions[i].dx,
                              top: draggablePositions[i].dy,
                              child: Image.asset(
                                widget.levelData["objects"][i],
                                width: 50.0,
                                height: 50.0,
                              ),
                            ),
                      ],
                    ),
                  )


                ],
              ),)
            ),
            const SizedBox(height: 16.0),
            // "Next" Button
            if (isCorrect)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DifferenceFindResultsScreen(score: total, moves: dragMoves, difficulty: widget.difficulty, timeTaken: stopwatch.elapsed.inSeconds , assisted: showHighlight),
                    ),
                  );
                //   score: 20, moves: dragMoves, difficulty: widget.difficulty, timeTaken: stopwatch.elapsed.inSeconds , assisted: showHighlight
                },
                child: const Text("Next"),
              ),
          ],
        ),
      ),
    );
  }
}
