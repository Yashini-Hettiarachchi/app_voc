import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/vocabuloary_performance_screen.dart' as vocabScreen; // Correct import with alias
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  String _getGrade(int difficulty) { // Added return type
    switch (difficulty) {
      case 0:
        return "Initial";
      case 1:
        return "Bronze";
      case 2:
        return "Silver";
      case 3:
        return "Gold";
      case 4:
        return "Platinum";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context);
    final username = session.fullName ?? "User";
    final difficulty = session.vocabularyDifficulty;

    return Scaffold(
      appBar: AppBar(
        title: Text('$username\'s Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $username", style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text("Email: ${session.email ?? 'N/A'}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Current Vocabulary Level: ${_getGrade(difficulty)} (Difficulty $difficulty)", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => vocabScreen.VocabularyPerformanceScreen()),
                );
              },
              child: Text('View Vocabulary Performance'),
            ),
          ],
        ),
      ),
    );
  }
}