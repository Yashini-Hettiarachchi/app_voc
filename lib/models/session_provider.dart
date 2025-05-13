import 'package:flutter/material.dart';

class SessionProvider extends ChangeNotifier {
  String? accessToken;
  String? refreshToken;
  String? userRole;
  String? authEmployeeID;

  // User details
  String? userId;
  String? username;
  String? fullName;
  String? email;
  String? contactNumber;
  List<String>? complications;
  DateTime? createdAt;

  // Vocabulary difficulty tracking
  int _vocabularyDifficulty = 0; // Default to lowest difficulty

  // Getter for vocabulary difficulty
  int get vocabularyDifficulty => _vocabularyDifficulty;

  void updateSession({
    required String accessToken,
    required String refreshToken,
    required String userRole,
    required String authEmployeeID,
    required String userId,
    required String username,
    required String fullName,
    required String email,
    required String contactNumber,
    required List<String> complications,
    required DateTime createdAt,
    int? vocabularyDifficulty, // Optional parameter to update difficulty during session update
  }) {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.userRole = userRole;
    this.authEmployeeID = authEmployeeID;

    // Update user details
    this.userId = userId;
    this.username = username;
    this.fullName = fullName;
    this.email = email;
    this.contactNumber = contactNumber;
    this.complications = complications;
    this.createdAt = createdAt;

    // Update vocabulary difficulty if provided
    if (vocabularyDifficulty != null) {
      _vocabularyDifficulty = vocabularyDifficulty;
    }

    notifyListeners();
  }

  // Method to update vocabulary difficulty independently
  void updateDifficulty(int difficulty) {
    _vocabularyDifficulty = difficulty;
    notifyListeners();
  }

  void clearSession() {
    accessToken = null;
    refreshToken = null;
    userRole = null;
    authEmployeeID = null;

    // Clear user details
    userId = null;
    username = null;
    fullName = null;
    email = null;
    contactNumber = null;
    complications = null;
    createdAt = null;

    // Reset vocabulary difficulty
    _vocabularyDifficulty = 0;

    notifyListeners();
  }
}