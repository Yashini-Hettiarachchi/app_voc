import 'dart:convert';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:chat_app/models/session_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInWindow extends StatefulWidget {
  @override
  _SignInWindowState createState() => _SignInWindowState();
}

class _SignInWindowState extends State<SignInWindow> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    // Check if the widget is still mounted before updating state
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    // Validate required fields
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both email and password')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // For testing purposes, we'll use a mock response
    try {
      print("Attempting sign-in with mock data");

      // Create mock user data with proper typing
      final Map<String, dynamic> mockUser = {
        "_id": "mock_user_id_123",
        "full_name": "Test User",
        "email": _usernameController.text,
        "username": _usernameController.text,
        "contact_number": "1234567890",
        "vocabulary": 0,
        "identify_difference": 0,
      };

      // Create mock response data with proper typing
      final Map<String, dynamic> mockData = {
        "access_token": "mock_access_token_123",
        "token_type": "bearer",
        "user": mockUser
      };

      // Store token in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', mockData['access_token'] as String);

      // Get user data from mock response
      final Map<String, dynamic> user =
          mockData['user'] as Map<String, dynamic>;

      // Set vocabulary difficulty
      int vocabularyDifficulty = (user['vocabulary'] as int?) ?? 0;

      // Update session provider
      if (mounted) {
        Provider.of<SessionProvider>(context, listen: false).updateSession(
          accessToken: mockData['access_token'] as String,
          refreshToken: "refreshToken",
          userRole: mockData['token_type'] as String,
          authEmployeeID: (user['_id'] as String?) ?? '0',
          complications: user['complications'] != null
              ? List<String>.from(user['complications'] as List)
              : [],
          contactNumber: (user['contact_number'] as String?) ?? '',
          createdAt: DateTime.now(),
          email: (user['email'] as String?) ?? '',
          fullName: (user['full_name'] as String?) ?? '',
          userId: (user['_id'] as String?) ?? '',
          username: (user['username'] as String?) ?? '',
          vocabularyDifficulty: vocabularyDifficulty,
        );
      }

      // Store session data in SharedPreferences
      await _storeSessionInSharedPreferences(
        mockData['access_token'] as String,
        "ref",
        "Patient",
        (user['_id'] as String?) ?? '',
        (user['email'] as String?) ?? '',
        (user['full_name'] as String?) ?? '',
        vocabularyDifficulty,
        (user['identify_difference'] as int?) ?? 1,
      );

      // Show success message and navigate to home screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign-in successful!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }

      /* Commented out for testing - original code
      final url = Uri.parse('${ENVConfig.serverUrl}/token');
      final signInData = {
        "guardian_email": _usernameController.text,
        "password": _passwordController.text,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signInData),
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception("Connection timeout. The server might be unavailable.");
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', data['access_token']);
        final user = data['user'];

        int vocabularyDifficulty = user['vocabulary'] ?? 0; // Default to 0 if not provided
        Provider.of<SessionProvider>(context, listen: false).updateSession(
          accessToken: data['access_token'],
          refreshToken: "refreshToken", // Replace with actual refresh token if available
          userRole: data['token_type'],
          authEmployeeID: user['_id'] ?? '0',
          complications: user['complications'] != null ? List<String>.from(user['complications']) : [],
          contactNumber: user['contact_number'] ?? '',
          createdAt: DateTime.now(),
          email: user['email'] ?? '',
          fullName: user['full_name'] ?? '',
          userId: user['_id'] ?? '',
          username: user['username'] ?? '',
          vocabularyDifficulty: vocabularyDifficulty,
        );

        await _storeSessionInSharedPreferences(
          data['access_token'],
          "ref",
          "Patient",
          user['_id'] ?? '',
          user['email'] ?? '',
          user['full_name'] ?? '',
          vocabularyDifficulty,
          user['identify_difference'] ?? 1,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in successful!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        String errorMessage;
        try {
          final responseData = jsonDecode(response.body);
          errorMessage = responseData['detail'] ?? 'Failed to sign in';
        } catch (e) {
          errorMessage = 'Failed to sign in: ${response.body}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      */
    } catch (error) {
      print("Sign-in error: $error");

      if (!mounted) return;

      String errorMessage = error.toString();

      if (errorMessage.contains("SocketException") ||
          errorMessage.contains("Connection refused") ||
          errorMessage.contains("Connection timeout") ||
          errorMessage.contains("Failed host lookup")) {
        errorMessage =
            "Cannot connect to the server. Please check your internet connection or try again later.";
      } else if (errorMessage.contains("FormatException")) {
        errorMessage =
            "Server returned an invalid response. Please try again later.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $errorMessage')),
      );
    } finally {
      // Check if the widget is still mounted before updating state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Styles.secondaryAccent),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.secondaryAccent),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.secondaryAccent),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Styles.secondaryAccent),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }

  Future<void> _storeSessionInSharedPreferences(
    String accessToken,
    String refreshToken,
    String userRole,
    String authEmployeeID,
    String email,
    String fullName, // Changed from full_name to fullName
    int vocab,
    int ident,
  ) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('accessToken', accessToken);
      prefs.setString('refreshToken', refreshToken);
      prefs.setString('userRole', userRole);
      prefs.setString('authEmployeeID', authEmployeeID);
      prefs.setString('email', email);
      prefs.setString(
          'full_name', fullName); // Still using 'full_name' as the key
      prefs.setInt('difference_difficulty', ident);
      prefs.setInt('vocabulary_difficulty', vocab);
    } catch (e) {
      // Using a safer approach than print for error logging
      debugPrint('Error storing session data in shared preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sign In',
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Fill details and Enter app',
                          style:
                              TextStyle(fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                  titleSpacing: 0,
                  leading: Container(
                    margin: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Color(0xff80ca84),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 2),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 40.0,
                      backgroundColor: Styles.secondaryAccent,
                      child:
                          Icon(Icons.person, size: 40.0, color: Colors.white),
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      controller: _usernameController,
                      style: TextStyle(color: Styles.fontLight),
                      decoration: _buildInputDecoration('Your Username'),
                    ),
                    SizedBox(height: 10.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Styles.fontLight),
                      decoration: _buildInputDecoration('Your Password'),
                    ),
                    SizedBox(height: 20.0),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.dangerColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Sign In'),
                          ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/sign-up'),
                      child: Text('Haven\'t got an Account?'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
