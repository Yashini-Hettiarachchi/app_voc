import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:chat_app/navigations/home_screen.dart';
import 'package:chat_app/navigations/landing_screen.dart';
import 'package:chat_app/navigations/signin_window.dart';
import 'package:chat_app/navigations/signup_window.dart';
import 'package:chat_app/navigations/vocabulary_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/session_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionProvider(),
      child: MaterialApp(
        title: 'NVLD App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(137, 217, 242, 1),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            titleTextStyle: GoogleFonts.poppins(fontSize: 15),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: Styles.shadowColor,
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(137, 217, 242, 1),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: Styles.shadowColor,
            ),
          ),
        ),
        home: Consumer<SessionProvider>(
          builder: (context, sessionProvider, _) {
            if (sessionProvider.authEmployeeID != null) {
              return const HomeScreen();
            } else {
              checkSharedPreferences(context);
              return const LandingPage();
            }
          },
        ),
        routes: {
          '/home': (context) => HomeScreen(),           // Removed const
          '/landing': (context) => LandingPage(),       // Removed const
          '/sign-up': (context) => SignUpWindow(),      // Removed const
          '/sign-in': (context) => SignInWindow(),      // Removed const
          '/vocabulary': (context) => VocabularyLevelsScreen(), // Removed const
        },
      ),
    );
  }

  Future<void> checkSharedPreferences(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authEmployeeID = prefs.getString('authEmployeeID');
    if (authEmployeeID != null) {
      Provider.of<SessionProvider>(context, listen: false).updateSession(
        accessToken: prefs.getString('accessToken').toString(),
        refreshToken: prefs.getString('refreshToken').toString(),
        userRole: prefs.getString('userRole').toString(),
        username: authEmployeeID,
        complications: [],
        contactNumber: '',
        createdAt: DateTime.parse('2022-04-05'),
        email: '',
        fullName: '',
        userId: '',
        authEmployeeID: '0',
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}