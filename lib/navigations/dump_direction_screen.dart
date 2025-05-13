import 'dart:convert';
import 'dart:typed_data';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/direction_levels_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DirectionScreen extends StatefulWidget {
  final Map<String, dynamic> levelData;

  const DirectionScreen({required this.levelData, Key? key}) : super(key: key);

  @override
  _DirectionScreenState createState() => _DirectionScreenState();
}

class _DirectionScreenState extends State<DirectionScreen> {
  Uint8List? generatedImage;
  bool isLoading = true;
  final Map<int, String?> userAnswers = {};
  late List<String> answerParts;
  late List<String> prepositions;
  late List<int> prepositionIndices;
  late Stopwatch stopwatch;
  int wrongPrepositionCount = 0; // Counter for wrong prepositions
  int attempts = 0; // Counter for user attempts
  String hint = '';
  bool show = false;

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch()..start();
    answerParts = widget.levelData['answer']?.split(' ') ?? [];
    prepositions = widget.levelData['options'] ?? [];
    prepositionIndices = _identifyPrepositionIndices();
    generateImageFromPrompt();
    hint = widget.levelData['clue'] ?? "Find the correct direction"; // Set initial hint
  }

  /// Identifies indices of words in the answer that are prepositions.
  List<int> _identifyPrepositionIndices() {
    return List.generate(answerParts.length, (index) {
      if (prepositions.contains(answerParts[index])) return index;
      return -1; // Mark non-preposition indices with -1
    }).where((index) => index != -1).toList();
  }

  Future<void> generateImageFromPrompt() async {
    const apiKey = 'DEZGO-E3892C6F00D69E6884C9A7F907306607D71183DD810B9DA21363DA510F818EFFA4E31415';
    const url = 'https://api.dezgo.com/text2image';

    final payload = {
      "prompt": widget.levelData['answer'] ?? "A simple indoor scene illustrating various object placements.",
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

  void _checkAnswers() async {
    stopwatch.stop();
    int correctAnswers = 0;
    List<String> correctPrepositions = widget.levelData['answer']?.split(' ') ?? [];

    for (int i = 0; i < prepositionIndices.length; i++) {
      int index = prepositionIndices[i];
      if (userAnswers[index] == correctPrepositions[index]) {
        correctAnswers++;
      } else {
        wrongPrepositionCount++;
      }
    }

    // Calculate score as a percentage
    double score = (correctAnswers / prepositionIndices.length) * 100;

    if (attempts >= 12) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DirectionLevelsScreen()),
      );
      return;
    }

    final timeTaken = stopwatch.elapsed.inSeconds;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Results", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "You selected $correctAnswers correct preposition(s) in $timeTaken seconds.",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            // Show the score in large font
            Text(
              "Score: ${score.toStringAsFixed(2)}%",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Save score to SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setDouble("difference_score", score);

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DirectionLevelsScreen()),
              );
            },
            child: const Text("Finish", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Return to Question", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor() {
    if (wrongPrepositionCount < 5) {
      return Colors.green;
    } else if (wrongPrepositionCount <= 10) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Change hint after 5 attempts
    if (attempts >= 5 && hint != 'Try again!') {
      setState(() {
        hint = 'Try again!';
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelData["title"] ?? "Direction Level"),
      ),
      backgroundColor: Styles.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            show && hint.isNotEmpty
                ? Text(
              hint,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )
                : const SizedBox(),
            const SizedBox(height: 20.0),
            // Circular badge for wrong attempts count
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    attempts.toString(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            if (isLoading)
              const CircularProgressIndicator()
            else if (generatedImage != null)
              Expanded(
                child: Image.memory(
                  generatedImage!,
                  fit: BoxFit.contain,
                ),
              )
            else
              const Expanded(
                child: Center(child: Text("Image could not be generated")),
              ),
            const SizedBox(height: 20.0),
            // Display the answer text with dropdowns for prepositions
            Expanded(
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: answerParts.asMap().entries.map((entry) {
                  int index = entry.key;
                  String word = entry.value;

                  if (prepositionIndices.contains(index)) {
                    return DropdownButton<String>(
                      value: userAnswers[index],
                      items: prepositions
                          .map(
                            (preposition) => DropdownMenuItem(
                          value: preposition,
                          child: Text(preposition),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          userAnswers[index] = value;
                          attempts++; // Increment attempts here
                          if (attempts >= 12) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DirectionLevelsScreen()),
                            );
                          }
                        });
                      },
                      hint: const Text("Select"),
                      dropdownColor: Colors.white,
                    );
                  } else {
                    return Text(word, style: const TextStyle(fontSize: 16));
                  }
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _checkAnswers,
        child: const Icon(Icons.check),
      ),
    );
  }

  @override
  void dispose() {
    stopwatch.stop();
    super.dispose();
  }
}
