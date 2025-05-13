import 'dart:convert';
import 'dart:io';
import 'package:chat_app/constants/env.dart';
import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SignUpWindow extends StatefulWidget {
  @override
  _SignUpWindowState createState() => _SignUpWindowState();
}

class _SignUpWindowState extends State<SignUpWindow> {
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianEmailController =
      TextEditingController();
  final TextEditingController _guardianContactController =
      TextEditingController();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _childAgeController = TextEditingController();
  final TextEditingController _childGenderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _complicationController = TextEditingController();

  File? _avatarImage;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  int _childAge = 4;
  String? _childGender;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAvatar() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _avatarImage = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<void> _signUp() async {
    // Check if the widget is still mounted before updating state
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    // Validate required fields
    if (_guardianNameController.text.isEmpty ||
        _guardianEmailController.text.isEmpty ||
        _guardianContactController.text.isEmpty ||
        _childNameController.text.isEmpty ||
        _childGender == null ||
        _passwordController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // Validate email format
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(_guardianEmailController.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid email address')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // Validate password length
    if (_passwordController.text.length < 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password must be at least 8 characters long')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // Validate contact number (should be numeric and have appropriate length)
    final contactRegExp = RegExp(r'^\d{10,15}$');
    if (!contactRegExp.hasMatch(_guardianContactController.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Please enter a valid contact number (10-15 digits)')),
        );
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    // Use a direct URL for testing
    final url = Uri.parse('http://localhost:8080/signup');

    // Create a simplified data structure for testing
    final signupData = {
      "guardian_name": _guardianNameController.text.trim(),
      "guardian_email": _guardianEmailController.text.trim(),
      "guardian_contact": _guardianContactController.text.trim(),
      "child_name": _childNameController.text.trim(),
      "child_age": _childAge,
      "child_gender": _childGender,
      "password": _passwordController.text,
      "vocabulary": 0,
      "identify_difference": 0
    };

    print("Using direct URL: $url");

    try {
      print("Sending sign-up request to: $url");

      // For testing purposes, we'll use a mock response instead of making an actual HTTP request
      // This will help us isolate the issue
      bool mockSuccess = true; // Set to false to simulate a failure

      if (mockSuccess) {
        // Simulate a successful response
        print("Using mock success response");

        // Check if the widget is still mounted before updating UI
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        // Simulate a failed response
        print("Using mock failure response");

        // Check if the widget is still mounted before updating UI
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed: Mock error')),
        );
      }

      /* Commented out for testing
      final response = await http
          .post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(signupData),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception("Connection timeout. The server might be unavailable.");
      });

      print("Sign-up response status code: ${response.statusCode}");

      // Check if the widget is still mounted before updating UI
      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pushReplacementNamed(context, '/sign-in');
      } else {
        String errorMessage;
        try {
          final responseData = jsonDecode(response.body);
          errorMessage = responseData['detail'] ?? 'Registration failed';
        } catch (e) {
          errorMessage = 'Registration failed: ${response.body}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
      */
    } catch (error) {
      print("Sign-up error: $error");

      if (!mounted) return;

      String errorMessage = error.toString();

      if (errorMessage.contains("SocketException") ||
          errorMessage.contains("Connection refused") ||
          errorMessage.contains("Connection timeout") ||
          errorMessage.contains("Failed host lookup")) {
        errorMessage =
            "Cannot connect to the server. Please check your internet connection or try again later.";
      } else if (errorMessage.contains("ngrok")) {
        errorMessage =
            "The server connection has expired. Please update the server URL.";
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
      hintStyle: TextStyle(color: Colors.white),
    );
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
                      Text('Sign Up',
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                      SizedBox(height: 4),
                      Text('Fill details to create account',
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
                    Text("Guardian Details",
                        style: TextStyle(
                            color: Styles.fontLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    TextField(
                        controller: _guardianNameController,
                        style: TextStyle(color: Styles.fontLight),
                        decoration: _buildInputDecoration('Guardian Name')),
                    SizedBox(height: 10.0),
                    TextField(
                        controller: _guardianEmailController,
                        style: TextStyle(color: Styles.fontLight),
                        decoration: _buildInputDecoration('Email')),
                    SizedBox(height: 10.0),
                    TextField(
                        controller: _guardianContactController,
                        style: TextStyle(color: Styles.fontLight),
                        decoration: _buildInputDecoration('Contact Number')),
                    SizedBox(height: 10.0),
                    Divider(color: Styles.secondaryAccent),
                    SizedBox(height: 12.0),
                    Text("Child Details",
                        style: TextStyle(
                            color: Styles.fontLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    TextField(
                        controller: _childNameController,
                        style: TextStyle(color: Styles.fontLight),
                        decoration: _buildInputDecoration('Child Name')),
                    SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Age',
                            style: TextStyle(
                                color: Styles.secondaryAccent, fontSize: 16)),
                        Slider(
                          value: _childAge.toDouble(),
                          min: 4,
                          max: 20,
                          inactiveColor: Styles.secondaryAccent,
                          divisions: 16,
                          label: _childAge.toString(),
                          onChanged: (value) {
                            setState(() {
                              _childAge = value.toInt();
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Styles.secondaryAccent),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _childGender,
                              hint: Text('Select Gender',
                                  style: TextStyle(color: Styles.fontLight)),
                              dropdownColor: Styles.fontHighlight,
                              items: _genderOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                setState(() {
                                  _childGender = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Text("Child Avatar",
                        style: TextStyle(
                            color: Styles.fontLight,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    Center(
                      child: GestureDetector(
                        onTap: _pickAvatar,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: _avatarImage != null
                                ? DecorationImage(
                                    image: FileImage(_avatarImage!),
                                    fit: BoxFit.cover)
                                : DecorationImage(
                                    image:
                                        AssetImage('assets/icons/profile.gif'),
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Styles.fontLight),
                      decoration: _buildInputDecoration('Password'),
                    ),
                    SizedBox(height: 20.0),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.dangerColor),
                            child: Text('Sign Up'),
                          ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/sign-in'),
                      child: Text('Already have an account? Sign In'),
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
    _guardianNameController.dispose();
    _guardianEmailController.dispose();
    _guardianContactController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    _childGenderController.dispose();
    _passwordController.dispose();
    _complicationController.dispose();
    super.dispose();
  }
}
