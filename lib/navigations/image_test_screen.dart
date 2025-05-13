import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:chat_app/navigations/vocablury_results_screen.dart';

class ImageTestScreen extends StatefulWidget {
  final Map<String, dynamic> levelData;

  ImageTestScreen({required this.levelData});

  @override
  _ImageTestScreenState createState() => _ImageTestScreenState();
}

class _ImageTestScreenState extends State<ImageTestScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  String spokenAnswer = "";
  String statusMessage = "";
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  Timer? _timer;
  int timeTakenInSeconds = 0;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();

    // Start timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    bool available = await _speechToText.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (error) => print('Speech Error: $error'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(onResult: (result) {
        setState(() {
          spokenAnswer = result.recognizedWords;
          _checkAnswer();
        });
      });
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speechToText.stop();
  }

  void _checkAnswer() {
    final currentQuestion = widget.levelData["questions"][currentQuestionIndex];
    if (spokenAnswer.toLowerCase().trim() ==
        currentQuestion["answer"].toLowerCase().trim()) {
      setState(() {
        statusMessage = "🎉 Correct! Great job! 👍";
        correctAnswers++;
      });
    } else {
      setState(() {
        statusMessage = "❌ Oops! Try again! 💪";
      });
    }
  }

  void _showCompletionPopup() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "🎊 Activity Completed! 🎊",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "⏱️ Time Taken: ${Duration(seconds: timeTakenInSeconds).inMinutes}m ${timeTakenInSeconds % 60}s\n"
                "🏆 Score: $correctAnswers/${widget.levelData["questions"].length}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "✨ What would you like to do next? ✨",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog
                Navigator.pop(context); // Return to the previous screen
              },
              child: const Text("Return"),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog

                // Calculate difficulty level based on the level data
                int difficulty = widget.levelData["difficulty"] ?? 1;

                // Navigate to the results screen with auto-generate flag
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VocabularyResultsScreen(
                      rawScore: correctAnswers,
                      timeTaken: timeTakenInSeconds,
                      difficulty: difficulty,
                      levelData: widget.levelData,
                      autoGenerateReport: true, // Auto-generate the report
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text("Generate Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.levelData["questions"];
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelData["title"] ?? "Image Test Level"),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display question with emoji
              Row(
                children: [
                  const Icon(
                    Icons.help_outline,
                    color: Colors.purple,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      currentQuestion["question"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Display image with decorative frame
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.purple,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.network(
                    currentQuestion["imagePath"],
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Speech-to-text functionality with emoji
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_isListening) {
                          _stopListening();
                        } else {
                          _startListening();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.red : Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: Colors.white,
                          size: 30.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          spokenAnswer.isNotEmpty
                              ? "🗣️ You said: $spokenAnswer"
                              : "🎤 Tap the microphone and speak your answer!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isListening ? Colors.red : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Answer options with emojis
              const Row(
                children: [
                  Icon(
                    Icons.touch_app,
                    color: Colors.orange,
                    size: 24,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "👇 Select an Option:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children:
                    (currentQuestion["options"] as List<String>).map((option) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        spokenAnswer = option;
                        _checkAnswer();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 15),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "✍️ Or write your answer below ✍️",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              // Signature pad for input with emoji
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 2),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: SizedBox(
                    height: 150.0,
                    child: SfSignaturePad(
                      backgroundColor: Colors.grey[200],
                      strokeColor: Colors.blue,
                      minimumStrokeWidth: 3.0,
                      maximumStrokeWidth: 6.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Status message with emoji
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: statusMessage.contains("Correct")
                      ? Colors.green
                      : (statusMessage.isEmpty ? Colors.blue : Colors.red),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      statusMessage.contains("Correct")
                          ? Icons.check_circle
                          : (statusMessage.isEmpty
                              ? Icons.info_outline
                              : Icons.error_outline),
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        statusMessage.isNotEmpty
                            ? statusMessage
                            : "🤔 Waiting for your answer...",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Next/Finish button with emoji
              Center(
                child: ElevatedButton.icon(
                  onPressed: currentQuestionIndex < questions.length - 1
                      ? () {
                          setState(() {
                            currentQuestionIndex++;
                            spokenAnswer = "";
                            statusMessage = "";
                          });
                        }
                      : _showCompletionPopup,
                  icon: Icon(
                    currentQuestionIndex < questions.length - 1
                        ? Icons.arrow_forward
                        : Icons.check_circle,
                    color: Colors.white,
                  ),
                  label: Text(
                    currentQuestionIndex < questions.length - 1
                        ? "Next Question ➡️"
                        : "Finish Activity 🎉",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentQuestionIndex < questions.length - 1
                        ? Colors.blue
                        : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
