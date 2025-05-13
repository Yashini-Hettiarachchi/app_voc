import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/chatbot_screen.dart';
import 'package:chat_app/navigations/control_panel_screen.dart';
import 'package:chat_app/navigations/difference_levels_screen.dart';
import 'package:chat_app/navigations/direction_levels_screen.dart';
import 'package:chat_app/navigations/profile_screen.dart';
import 'package:chat_app/navigations/puzzle_levels_screen.dart';
import 'package:chat_app/navigations/vocabulary_list_screen.dart';
import 'package:chat_app/widgets/custom_card.dart';
import 'package:chat_app/widgets/idea_card.dart';
import 'package:chat_app/widgets/long_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _imagePositionX = -30;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), _animateImage);
  }

  void _animateImage() {
    setState(() {
      _imagePositionX = 400;
    });
  }

  String _getGrade(int difficulty) {
    switch (difficulty) {
      case 0: return "Initial";
      case 1: return "Bronze";
      case 2: return "Silver";
      case 3: return "Gold";
      case 4: return "Platinum";
      default: return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context);
    final username = session.fullName ?? "User";
    final difficulty = session.vocabularyDifficulty;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/backgrounds/1737431469670.png_image.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome Kiddo!", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                          Text("Level: ${_getGrade(difficulty)}", style: TextStyle(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: Color(0xff80ca84),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.yellow.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.logout, color: Colors.white),
                          onPressed: () async {
                            Provider.of<SessionProvider>(context, listen: false).clearSession();
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.remove('accessToken');
                            await prefs.remove('refreshToken');
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
                  SizedBox(height: 10),
                  const CustomCard(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: IdeaCard(
                          title: "Get Information",
                          icon: Icons.house,
                          navigationWindow: ProfileScreen(),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: IdeaCard(
                          title: "Your Profile",
                          icon: Icons.verified_user_rounded,
                          navigationWindow: ControlPanelScreen(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("ACTIVITIES", style: TextStyle(fontSize: 15, color: Color(0xFF232426), fontWeight: FontWeight.bold, fontFamily: "Rubik")),
                  // const SizedBox(height: 5),
                  // LongCard(title: "Puzzle Game", icon: Icons.dashboard, navigationWindow: PuzzleLevelsScreen(), backgroundColor: Colors.green),
                  const SizedBox(height: 5),
                  LongCard(title: "Identify Differences", icon: Icons.check, navigationWindow: DifferenceRecognitionLevelsScreen(), backgroundColor: Colors.purple),
                  const SizedBox(height: 5),
                  LongCard(title: "Prepositions", icon: Icons.question_answer, navigationWindow: DirectionLevelsScreen(), backgroundColor: Colors.redAccent),
                  const SizedBox(height: 5),
                  LongCard(title: "Vocabulary", icon: Icons.leaderboard, navigationWindow: VocabularyLevelsScreen(), backgroundColor: Colors.orange),
                  const SizedBox(height: 10),
                ],
              ),
              AnimatedPositioned(
                bottom: -80,
                left: _imagePositionX,
                duration: Duration(seconds: 20),
                curve: Curves.easeInOut,
                child: Image.asset('assets/icons/toys.png', width: 200, height: 200, fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }
}