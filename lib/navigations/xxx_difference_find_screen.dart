import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:chat_app/navigations/difference_find_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:chat_app/navigations/difference_levels_screen.dart';

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
  final List<Offset> draggablePositions = [];
  final List<Offset> staticPositions = [];
  late int missingObjectIndex;
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

    // Randomly generate positions for draggable objects
    for (int i = 0; i < widget.levelData["objects"].length; i++) {
      draggablePositions.add(
        Offset(
          random.nextDouble() * 200 + 50, // Random X position
          random.nextDouble() * 150 + 50, // Random Y position
        ),
      );
    }

    // Randomly choose one object to be missing in the static section
    missingObjectIndex = random.nextInt(widget.levelData["objects"].length);

    // Generate positions for static objects, excluding the missing one
    for (int i = 0; i < widget.levelData["objects"].length; i++) {
      if (i != missingObjectIndex) {
        staticPositions.add(
          Offset(
            random.nextDouble() * 200 + 50, // Random X position
            random.nextDouble() * 150 + 300, // Random Y position (below draggable area)
          ),
        );
      }
    }

    // Initialize the stopwatch
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

    double timePenalty = (elapsedSeconds > baseTimeThreshold)
        ? maxTimePenalty *
        ((elapsedSeconds - baseTimeThreshold) / baseTimeThreshold)
        : 0;

    double movesPenalty = (dragMoves > baseMovesThreshold)
        ? maxMovesPenalty * ((dragMoves - baseMovesThreshold) / baseMovesThreshold)
        : 0;

    // Ensure penalties don't exceed their respective caps
    timePenalty = timePenalty.clamp(0, maxTimePenalty) as double;
    movesPenalty = movesPenalty.clamp(0, maxMovesPenalty) as double;


    int score = (maxScore - timePenalty - movesPenalty).toInt();

    // Cap score to 60 if highlight was used
    if (showHighlight) {
      score = score.clamp(0, 60);
    }

    setState(() {
      total = score;
    });
  }

  void _showStatsPopup() {
    final elapsedSeconds = stopwatch.elapsed.inSeconds;

    // Calculate score
    const int maxScore = 100;
    const int maxTimePenalty = 40; // Maximum penalty for time
    const int maxMovesPenalty = 30; // Maximum penalty for drag moves
    const int baseTimeThreshold = 60; // Time threshold for penalties
    const int baseMovesThreshold = 20; // Drag move threshold for penalties

    double timePenalty = (elapsedSeconds > baseTimeThreshold)
        ? maxTimePenalty *
        ((elapsedSeconds - baseTimeThreshold) / baseTimeThreshold)
        : 0;

    double movesPenalty = (dragMoves > baseMovesThreshold)
        ? maxMovesPenalty * ((dragMoves - baseMovesThreshold) / baseMovesThreshold)
        : 0;

    // Ensure penalties don't exceed their respective caps
    timePenalty = timePenalty.clamp(0, maxTimePenalty) as double;
    movesPenalty = movesPenalty.clamp(0, maxMovesPenalty) as double;


    int score = (maxScore - timePenalty - movesPenalty).toInt();

    // Cap score to 60 if highlight was used
    if (showHighlight) {
      score = score.clamp(0, 60);
    }

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
      appBar: AppBar(
        title: Text(widget.levelData["title"]),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // First Expanded section with draggable objects
            Expanded(
              flex: 4,
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
                            if (i == missingObjectIndex &&
                                details.offset.dy >
                                    MediaQuery.of(context).size.height * 0.5) {
                              isCorrect = true;
                              stopwatch.stop();
                              calculateScore();
                            } else {
                              draggablePositions[i] = Offset(
                                details.offset.dx - 10,
                                details.offset.dy -
                                    AppBar().preferredSize.height -
                                    10,
                              );
                            }
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Instructional Text
            Text(
              isCorrect
                  ? "Correct!"
                  : "Find the difference in the below image.",
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.white60,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            // Second Expanded section with static objects
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
                            if (i != missingObjectIndex)
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
                      )
                  )
                ],
              ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showStatsPopup,
        child: const Icon(Icons.info),
      ),
    );
  }
}
