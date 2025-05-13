// import 'package:chat_app/constants/styles.dart';
// import 'package:chat_app/navigations/home_screen.dart';
// import 'package:chat_app/navigations/jigsaw_screen.dart';
// import 'package:chat_app/navigations/puzzle_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class PuzzleLevelsScreen extends StatefulWidget {
//   @override
//   _PuzzleLevelsScreenState createState() => _PuzzleLevelsScreenState();
// }
//
// class _PuzzleLevelsScreenState extends State<PuzzleLevelsScreen> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   int _diff = 0;
//
//   // Sample data for levels
//   final List<Map<String, String>> levels = [
//     {
//       "title": "Level 1",
//       "clue": "Find the hidden key!",
//       "image": "assets/images/puzzle.png",
//     },
//     {
//       "title": "Level 2",
//       "clue": "Solve the puzzle to unlock the door.",
//       "image": "assets/images/puzzle.png",
//     },
//     {
//       "title": "Level 3",
//       "clue": "Decipher the code!",
//       "image": "assets/images/puzzle.png",
//     },
//     // Add more levels as needed
//   ];
//
//   void _playInstructions() async {
//     await _audioPlayer.play(AssetSource("assets/audios/puzzle.mp3"));
//   }
//
//   Future<void> _loadDifficulty() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? d = prefs.getInt('puzzle_difficulty');
//     setState(() {
//       _diff = d ?? 0;
//     });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadDifficulty();
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   void _navigateToPuzzleScreen(Map<String, String> levelData, int index) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => JigsawHomePage(difficulty: 1, factor: index + _diff,),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Puzzle Levels'),
//       ),
//       backgroundColor: Styles.secondaryColor,
//       body: Column(
//         children: [
//           // Top card with title, description, and play button
//           Padding(
//             padding: const EdgeInsets.all(16.0), // Padding around the container
//             child: Container(
//               height: 200,
//               padding: const EdgeInsets.all(16.0), // Inner padding for the container's content
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade100,
//                 borderRadius: BorderRadius.circular(12.0),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "Welcome to Puzzle World! Level $_diff",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 8.0),
//                   const Text(
//                     "Choose a level to start solving puzzles and follow the instructions carefully.",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   const Spacer(),
//                   ElevatedButton.icon(
//                     onPressed: _playInstructions,
//                     icon: const Icon(Icons.play_arrow),
//                     label: const Text("Play Instructions"),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 16.0),
//           // List view of level cards
//           Expanded(
//             child: ListView.builder(
//               itemCount: levels.length,
//               itemBuilder: (context, index) {
//                 final level = levels[index];
//                 return GestureDetector(
//                   onTap: () => _navigateToPuzzleScreen(level, index),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10.0),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Row(
//                           children: [
//                             Image.asset(
//                               level["image"]!,
//                               width: 60.0,
//                               height: 60.0,
//                               fit: BoxFit.cover,
//                             ),
//                             const SizedBox(width: 16.0),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     level["title"]!,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4.0),
//                                   Text(
//                                     level["clue"]!,
//                                     style: const TextStyle(fontSize: 14, color: Colors.white60),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: (){
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => HomeScreen()),
//           );
//         },
//         child: const Icon(Icons.home),
//       ),
//     );
//   }
// }
