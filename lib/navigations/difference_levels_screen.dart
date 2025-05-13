import 'dart:math';

import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:chat_app/navigations/previous_difference_records_screen.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:chat_app/navigations/difference_find_screen.dart';

class DifferenceRecognitionLevelsScreen extends StatefulWidget {
  @override
  _DifferenceRecognitionLevelsScreenState createState() =>
      _DifferenceRecognitionLevelsScreenState();
}

class _DifferenceRecognitionLevelsScreenState
    extends State<DifferenceRecognitionLevelsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _diff = 1;
  int levelsToShow = 1;

  // Sample data for levels
  final List<Map<String, dynamic>> levels = [
    {
      "title": "School Desk",
      "desc": "Spot the differences on the school desk.",
      "background": "assets/images/desk/wood-desk.jpg",
      "hint": "plain wooden surface filled in image",
      "color": Color(0xFF2ECC71),
      "objects": [
        "assets/images/desk/book1.png",
        "assets/images/desk/pen2.png",
        "assets/images/desk/pen1.png",
        "assets/images/desk/pencil1.png",
        "assets/images/desk/eraser1.png",
        "assets/images/desk/pen4.png",
        "assets/images/desk/stick.png",
        "assets/images/desk/stick2.png",
        "assets/images/desk/papers.png",
      ],
    },
    {
      "title": "Kitchen Desk",
      "desc": "Metal kitchen desk as background",
      "background": "assets/images/desk/desk.jpg",
      "hint": "plain metal surface as background image.",
      "color": Color(0xFF2ECC71),
      "objects": [
        "assets/images/kitchen/cup.png",
        "assets/images/kitchen/cutting.png",
        "assets/images/kitchen/fork.png",
        "assets/images/kitchen/knife.png",
        "assets/images/kitchen/potatoe.png",
        "assets/images/kitchen/spoon.png",
        "assets/images/desk/stick.png",
        "assets/images/desk/stick2.png",
        "assets/images/desk/papers.png",
      ],
    },
    {
      "title": "Classroom Board",
      "desc": "Find the differences on the classroom board.",
      "background": "assets/images/desk/board.jpg",
      "hint": "Classroom board with messy items around.",
      "color": Color(0xff27a5c6),
      "objects": [
        "assets/images/desk/book1.png",
        "assets/images/desk/pen2.png",
        "assets/images/desk/pen1.png",
        "assets/images/desk/pencil1.png",
        "assets/images/desk/eraser1.png",
        "assets/images/desk/pen4.png",
        "assets/images/desk/stick.png",
        "assets/images/desk/stick2.png",
        "assets/images/desk/papers.png",
      ],
    },
    {
      "title": "Library Desk",
      "desc": "Spot the differences on the library desk.",
      "background": "assets/images/desk/desk.jpg",
      "hint": "Library desk filled with books and stationery.",
      "color": Color(0xFFF0932B),
      "objects": [
        "assets/images/desk/book1.png",
        "assets/images/desk/pen2.png",
        "assets/images/desk/pen1.png",
        "assets/images/desk/pencil1.png",
        "assets/images/desk/eraser1.png",
        "assets/images/desk/pen4.png",
        "assets/images/desk/stick.png",
        "assets/images/desk/stick2.png",
        "assets/images/desk/papers.png",
      ],
    },
    {
      "title": "Kitchen Desk",
      "desc": "Spot the different objects on kitchen desk.",
      "background": "assets/images/desk/desk.jpg",
      "hint": "plain metal surface as background image.",
      "color": Color(0xFFEB4D4B),
      "objects": [
        "assets/images/desk/book1.png",
        "assets/images/desk/pen2.png",
        "assets/images/desk/pen1.png",
        "assets/images/desk/pencil1.png",
        "assets/images/desk/eraser1.png",
        "assets/images/desk/pen4.png",
        "assets/images/desk/stick.png",
        "assets/images/desk/stick2.png",
        "assets/images/desk/papers.png",
      ],
    },
    {
      "title": "Kitchen Desk",
      "desc": "Spot the different objects on kitchen desk.",
      "background": "assets/images/desk/desk.jpg",
      "hint": "plain metal surface as background image.",
      "color": Color(0xFF2ECC71),
      "objects": [
        "assets/images/desk/book1.png",
        "assets/images/desk/pen2.png",
        "assets/images/desk/pen1.png",
        "assets/images/desk/pencil1.png",
        "assets/images/desk/eraser1.png",
        "assets/images/desk/pen4.png",
        "assets/images/desk/stick.png",
        "assets/images/desk/stick2.png",
        "assets/images/desk/papers.png",
      ],
    },
  ];

  void _playInstructionsAudio() async {
    await _audioPlayer.play(AssetSource("assets/audios/differences_instructions.mp3"));
  }

  Future<void> _loadDifficulty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? d = prefs.getInt('difference_difficulty');

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

  void _navigateToNextScreen(Map<String, dynamic> levelData) {
    // Adjust objects based on difficulty level
    List<String> objects = List<String>.from(levelData["objects"]);
    if (_diff == 1 || _diff == 0) {
      objects = objects.take(3).toList(); // Easy: Use only first 3 objects
    } else if (_diff == 2) {
      objects = objects.take(4).toList(); // Medium: Use first 5 objects
    } else if (_diff == 3) {
      objects = objects.take(5).toList(); // Medium: Use first 5 objects
    } else if (_diff == 4) {
      objects = objects.take(6).toList(); // Medium: Use first 5 objects
    }

    // Shuffle the objects
    objects.shuffle(Random());

    // Pass modified levelData with shuffled objects
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DifferenceFindScreen(
          levelData: {...levelData, "objects": objects},
          difficulty: _diff,
        ),
      ),
    );
  }

  void _showDemoVideo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: DemoVideoPlayer(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Stack(
        children: [
          Container(
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
                          'Identify Difference and Drop',
                          style: TextStyle(
                            fontSize: 20, // Main title font size
                            color: Colors.black, // Text color
                          ),
                        ),
                        SizedBox(height: 4), // Space between title and subtitle
                        Text(
                          'Difficulty Level ${_diff.toString()}',
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
                          "Welcome to Identify Difference Game!",
                          style: TextStyle(fontSize: 20, color: Color(0xFFFCE6F6),  fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        const Text(
                          "Choose a level to start finding the differences in various scenes.",
                          style: TextStyle(fontSize: 16, color: Color(0xFFD4D4D4)),
                        ),
                        const Spacer(),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space out buttons evenly
                          children: [
                            ElevatedButton.icon(
                              onPressed: _showDemoVideo,
                              icon: const Icon(Icons.play_circle_filled),
                              label: const Text("Demo Video"),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => PreviousDifferenceRecordsScreen()),
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
                const SizedBox(height: 2.0),
                // List view of level cards
                Expanded(
                  child: ListView.builder(
                    itemCount: levels.length,
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      final isLocked = index >= levelsToShow+1;
                      return Stack(
                        children: [
                          // Main Level Card
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: GestureDetector(
                              onTap: () {
                                if (isLocked) {
                                  // Show a loader message when attempting to access a locked level
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const CircularProgressIndicator(),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Level locked! Unlock by increasing difficulty.",
                                              style: const TextStyle(fontSize: 16),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Close"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  _navigateToNextScreen(level);
                                }
                              },
                              child: Card(
                                color: level["color"],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        level["background"],
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
                                              level["title"],
                                              style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4.0),
                                            Text(
                                              level["desc"],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isLocked)
                                        const Icon(
                                          Icons.lock,
                                          color: Colors.red,
                                          size: 24.0,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Lock overlay for locked levels
                          if (isLocked)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8), // Space between icon and text
                                    Text(
                                      "Level Locked",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4), // Optional space for a second line of text
                                    Text(
                                      "Complete Difficulty level ${index+1} to unlock.",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff80ca84),
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

class DemoVideoPlayer extends StatefulWidget {
  @override
  _DemoVideoPlayerState createState() => _DemoVideoPlayerState();
}

class _DemoVideoPlayerState extends State<DemoVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/videos/difference-demo.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        children: [
          Expanded(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : const Center(child: CircularProgressIndicator()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
