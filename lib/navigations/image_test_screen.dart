import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

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
    if (spokenAnswer.toLowerCase().trim() == currentQuestion["answer"].toLowerCase().trim()) {
      setState(() {
        statusMessage = "Correct!";
        correctAnswers++;
      });
    } else {
      setState(() {
        statusMessage = "Incorrect. Try again!";
      });
    }
  }

  void _showCompletionPopup() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Activity Completed"),
          content: Text(
            "Time Taken: ${Duration(seconds: timeTakenInSeconds).inMinutes}m ${timeTakenInSeconds % 60}s\n"
                "Score: $correctAnswers/${widget.levelData["questions"].length}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss the dialog
                Navigator.pop(context); // Return to the previous screen
              },
              child: const Text("OK"),
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
              // Display question
              Text(
                currentQuestion["question"],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Display image
              Center(
                child: Image.network(
                  currentQuestion["imagePath"],
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),

              // Speech-to-text functionality
              Row(
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
                    child: Icon(
                      Icons.mic,
                      color: _isListening ? Colors.red : Colors.blue,
                      size: 30.0,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        spokenAnswer.isNotEmpty ? "Spoken: $spokenAnswer" : "Speak your answer",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Answer options
              const Text("Select an Option:", style: TextStyle(fontSize: 14)),
              Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children: (currentQuestion["options"] as List<String>).map((option) {
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        spokenAnswer = option;
                        _checkAnswer();
                      });
                    },
                    child: Text(option),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              const Text("Or", style: TextStyle(fontSize: 12)),

              // Signature pad for input
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: SizedBox(
                  height: 200.0,
                  child: SfSignaturePad(
                    backgroundColor: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Status message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: statusMessage == "Correct!" ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  statusMessage.isNotEmpty ? statusMessage : "Provide an answer",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Next/Finish button
              Center(
                child: ElevatedButton(
                  onPressed: currentQuestionIndex < questions.length - 1
                      ? () {
                    setState(() {
                      currentQuestionIndex++;
                      spokenAnswer = "";
                      statusMessage = "";
                    });
                  }
                      : _showCompletionPopup,
                  child: Text(currentQuestionIndex < questions.length - 1 ? "Next" : "Finish"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
