import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/vocabulary_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuggestedActivitiesScreen extends StatelessWidget {
  final int totalScore;

  const SuggestedActivitiesScreen({Key? key, required this.totalScore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VocabularyLevelsScreen()),
            );
          },
          backgroundColor: Color(0xff80ca84),
          child: const Icon(
            Icons.list,
            color: Colors.white,
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgrounds/fb3f8dc3b3e13aebe66e9ae3df8362e9.jpg'),
              fit: BoxFit.cover,
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
                        'Vocabulary Activity Summary',
                        style: TextStyle(
                          fontSize: 20, // Main title font size
                          color: Colors.black, // Text color
                        ),
                      ),
                      SizedBox(height: 4), // Space between title and subtitle
                      Text(
                        'Difficulty ',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: totalScore >= 60 ? Colors.green.shade100 : Colors.yellow.shade100,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full-width image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12.0), // Match the container's corner radius
                            child: Image.asset(
                              'assets/images/voca.jpg', // Replace with your image path
                              fit: BoxFit.cover,
                              width: double.infinity, // Ensures full width
                              height: 150.0, // Set a specific height for the image
                            ),
                          ),
                          const SizedBox(height: 16.0), // Space between image and text
                          Text(
                            "Based on your score ($totalScore%), here are some suggestions:",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16.0),
                          if (totalScore >= 95) ...[
                            Text("- Explore advanced vocabulary exercises.", style: const TextStyle(fontSize: 16)),
                            Text("- Try challenging word puzzles.", style: const TextStyle(fontSize: 16)),
                            Text("- Mentor someone in vocabulary building.", style: const TextStyle(fontSize: 16)),
                          ] else if (totalScore >= 75) ...[
                            Text("- Practice daily quizzes to maintain your streak.", style: const TextStyle(fontSize: 16)),
                            Text("- Read more advanced articles or books.", style: const TextStyle(fontSize: 16)),
                            Text("- Join a vocabulary challenge group.", style: const TextStyle(fontSize: 16)),
                          ] else if (totalScore >= 60) ...[
                            Text("- Work on improving commonly missed words.", style: const TextStyle(fontSize: 16)),
                            Text("- Solve moderate-level vocabulary puzzles.", style: const TextStyle(fontSize: 16)),
                            Text("- Set a weekly vocabulary improvement goal.", style: const TextStyle(fontSize: 16)),
                          ] else if (totalScore >= 30) ...[
                            Text("- Start with basic vocabulary-building apps.", style: const TextStyle(fontSize: 16)),
                            Text("- Practice flashcards for new words daily.", style: const TextStyle(fontSize: 16)),
                            Text("- Read simple articles and highlight new words.", style: const TextStyle(fontSize: 16)),
                          ] else ...[
                            Text("- Begin with foundational word-building exercises.", style: const TextStyle(fontSize: 16)),
                            Text("- Use picture-based vocabulary tools.", style: const TextStyle(fontSize: 16)),
                            Text("- Try speaking aloud to enhance retention.", style: const TextStyle(fontSize: 16)),
                          ],
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}