import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:chat_app/navigations/signin_window.dart';
import 'package:chat_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool isSessionAvailable = false; // Track session availability

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isSessionAvailable = prefs.getString('authEmployeeID') != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgrounds/1737431405692.png_image(1).png'), // Replace with your background image
            fit: BoxFit.cover, // Ensure the image covers the entire screen
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/brain.png', // Replace with your dementia app logo
                  height: 300,
                ),
                const Text(
                  'MAGIC MIND',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                    fontFamily: 'Rubik',
                    shadows: [
                      Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Color(0x55000000),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'A child activity app designed for special purposes to enhance learning and engagement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFF5CD3),
                    fontFamily: 'ABeeZee',
                  ),
                ),
                const SizedBox(height: 30),

                // Conditionally display the "To Dashboard" button
                if (isSessionAvailable)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: CustomButton(
                      text: 'To Dashboard',
                      textColor: Colors.white,
                      prColor: Styles.secondaryAccent,
                      seColor: Styles.secondaryColor,
                      icon: Icons.dashboard_customize,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: CustomButton(
                    text: 'Join with Us',
                    textColor: Colors.white,
                    prColor: Styles.fontHighlight2,
                    seColor: Styles.dangerColor,
                    icon: Icons.app_registration,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignInWindow()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
