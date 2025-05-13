import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/direction_screen.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class DirectionLevelsScreen extends StatefulWidget {
  @override
  _DirectionLevelsScreenState createState() => _DirectionLevelsScreenState();
}

class _DirectionLevelsScreenState extends State<DirectionLevelsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Sample data for direction levels
  final List<Map<String, dynamic>> levels = [
    // {
    //   "title": "Level 1",
    //   "clue": "Find the object under the table.",
    //   "image": "assets/images/object.png",
    //   "answer": "Put a table in a room and keep a ball on the table in 2d cartoon.",
    // },
    {
      "title": "Level 1",
      "clue": "Find the object **on** the chair.",
      "image": "assets/images/object.png",
      "answer": "Place the book on the chair in 2d cartoon.",
      "options": ["on", "under", "behind", "next to"], // Correct: "on"
    },
    {
      "title": "Level 2",
      "clue": "Find the object **on wall of** given image.",
      "image": "assets/images/object.png",
      "answer": "Place a photo on wall beside two wall lights in 2d cartoon.",
      "options": ["on", "behind", "beside", "above"], // Correct: "in front of"
    },
    {
      "title": "Level 3",
      "clue": "Find the object **behind** the door.",
      "image": "assets/images/object.png",
      "answer": "Place the bag behind the door in 2d cartoon.",
      "options": ["behind", "in front of", "under", "next to"], // Correct: "behind"
    },
    {
      "title": "Level 4",
      "clue": "Find the object **next to** the lamp.",
      "image": "assets/images/object.png",
      "answer": "Place the vase next to the lamp in 2d cartoon..",
      "options": ["next to", "on", "behind", "above"], // Correct: "next to"
    },
    {
      "title": "Level 5",
      "clue": "Find the object **inside** the box.",
      "image": "assets/images/object.png",
      "answer": "Place the toy inside the box in 2d cartoon.",
      "options": ["inside", "on", "next to", "under"], // Correct: "inside"
    },
    {
      "title": "Level 6",
      "clue": "Find the object **above** the bed.",
      "image": "assets/images/object.png",
      "answer": "Place the clock above the bed in 2d cartoon.",
      "options": ["above", "under", "on", "next to"], // Correct: "above"
    },
    {
      "title": "Level 7",
      "clue": "Find the object **between** the chairs.",
      "image": "assets/images/object.png",
      "answer": "Place the table between the chairs in 2d cartoon.",
      "options": ["between", "on", "next to", "above"], // Correct: "between"
    },
  ];

  void _playInstructions() async {
    await _audioPlayer.play(AssetSource("assets/audios/direction_instructions.mp3"));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _navigateToDirectionScreen(Map<String, dynamic> levelData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DirectionScreen(levelData: levelData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direction Levels'),
      ),
      backgroundColor: Styles.secondaryColor,
      body: Column(
        children: [
          // Top card with title, description, and play button
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
                  const Text(
                    "Welcome to Direction World!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    "Choose a level to learn about prepositions by locating objects. Follow the instructions carefully.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _playInstructions,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Play Instructions"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16.0),
          // List view of level cards
          Expanded(
            child: ListView.builder(
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                return GestureDetector(
                  onTap: () => _navigateToDirectionScreen(level),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Image.asset(
                              level["image"]!,
                              width: 60.0,
                              height: 60.0,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    level["title"]!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  Text(
                                    level["clue"]!,
                                    style: const TextStyle(fontSize: 14, color: Colors.white60),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}
