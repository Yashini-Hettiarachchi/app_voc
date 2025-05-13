  Future<void> updateVocabScore(int predictedDifficulty) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('authEmployeeID');

      final updateData = {
        "vocabulary": predictedDifficulty,
      };

      try {
        final response = await http
            .put(
              Uri.parse('${ENVConfig.serverUrl}/users/$userId/update_score'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(updateData),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200 && mounted) {
          debugPrint('Score updated successfully on server');
          // No need to show a snackbar for this operation
        } else {
          debugPrint(
              'Failed to update score on server: ${response.statusCode}');
          // Save locally instead
          await prefs.setInt('vocabulary_level', predictedDifficulty);
        }
      } catch (serverError) {
        debugPrint('Server error when updating score: $serverError');
        // Save locally as fallback
        await prefs.setInt('vocabulary_level', predictedDifficulty);
      }
    } catch (e) {
      debugPrint('Error in updateVocabScore: $e');
      // No need to show error to user for this operation
    }
  }

  void _calculateTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    int difficulty = prefs.getInt('vocabulary_difficulty') ?? 1;

    // Calculate score based on exactly 10 questions per level
    // Each question is worth 10 points, with time factor deduction
    double timeFactor = widget.timeTaken * 0.05;
    totalScore = ((100 * widget.rawScore / 10) - timeFactor).toInt();

    await _saveScoreToDB(totalScore, difficulty.clamp(1, 5));

    if (totalScore > 60) {
      difficulty += 1;
    } else if (totalScore > 30) {
      // Keep the same difficulty
    } else {
      difficulty = (difficulty - 1).clamp(0, double.infinity).toInt();
    }

    totalScore = totalScore.clamp(0, 100);
    await prefs.setInt('vocabulary_difficulty', difficulty.clamp(1, 5));
    await prefs.setInt('last_time_taken', widget.timeTaken);
    updateVocabScore(difficulty.clamp(1, 5));

    setState(() {});
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String getMotivationalMessage() {
    if (totalScore >= 95) {
      return "🌟 AMAZING WORK! 🌟 You're a WORD SUPERSTAR! Your brain is super powerful!";
    } else if (totalScore >= 75) {
      return "🎉 FANTASTIC JOB! 🎉 You're getting really good at words! Keep it up!";
    } else if (totalScore >= 60) {
      return "👍 GREAT EFFORT! 👍 You're learning so many words! Practice makes perfect!";
    } else if (totalScore >= 30) {
      return "😊 GOOD TRY! 😊 You're getting better every time! Don't give up!";
    } else {
      return "🌱 KEEP GROWING! 🌱 Every time you practice, your brain gets stronger!";
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final DateFormat formatter = DateFormat('MMM dd, yyyy');
      return formatter.format(date);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return dateString;
    }
  }

  // Create a simple performance summary for the PDF
  pw.Widget _buildPerformanceSummary() {
    if (records.isEmpty) {
      return pw.Container();
    }

    // Create a simple text-based summary
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text("Performance Summary:",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(
            "Your vocabulary skills have ${comparison['score_change'] ?? 'changed'} over time."),
        pw.Text(
            "Your most recent score: ${records.isNotEmpty ? '${records[0]['score']}%' : 'N/A'}"),
        pw.Text("Your average score: ${_calculateAverageScore()}%"),
        pw.Text("Your current level: ${_getGrade(widget.difficulty)}"),
        pw.SizedBox(height: 8),
        pw.Text("Keep practicing to improve your vocabulary skills!"),
      ],
    );
  }

  // Calculate average score from records
  String _calculateAverageScore() {
    if (records.isEmpty) return "0";

    double sum = 0;
    for (var record in records) {
      sum += _sanitizeScore(record['score']);
    }
    return (sum / records.length).toStringAsFixed(1);
  }

  Future<void> _fetchVocabularyRecords() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String username = prefs.getString('authEmployeeID') ?? "sampleUser";

      debugPrint('Fetching vocabulary records for user: $username');
      debugPrint(
          'URL: ${ENVConfig.serverUrl}/vocabulary-records/user/$username');

      final response = await http
          .get(
        Uri.parse('${ENVConfig.serverUrl}/vocabulary-records/user/$username'),
      )
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('Request timed out');
        // Return a fake response instead of throwing an exception
        return http.Response('{"error": "timeout"}', 408);
      });

      debugPrint('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint(
            'Received data: ${data.toString().substring(0, min(100, data.toString().length))}...');

        if (mounted) {
          setState(() {
            records = data['records'] ?? [];
            comparison = data['comparison'] ?? {};

            // Generate score points for chart
            if (records.isNotEmpty) {
              scorePoints = _generateScorePoints(records);
            }

            isLoading = false;
          });
        }
      } else if (response.statusCode == 404) {
        debugPrint('No records found for user: $username');
        // If no records found, use empty records but don't show mock data
        if (mounted) {
          setState(() {
            records = [];
            comparison = {};
            isLoading = false;
          });
        }
      } else {
        debugPrint('Server returned error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        // Use mock data if server returns error
        _useMockData();
      }

      // Generate personalized suggestions
      _generatePersonalizedSuggestions();
    } catch (e) {
      debugPrint('Error fetching vocabulary records: $e');
      // Use mock data if server connection fails
      _useMockData();
    }
  }
