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

  Future<void> _generateAndShowPDF() async {
    setState(() {
      isLoading = true;
    });

    await _fetchVocabularyRecords();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Vocabulary Results",
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text("Total Score: $totalScore%"),
            pw.Text("Time Taken: ${formatTime(widget.timeTaken)}"),
            pw.Text("Raw Score: ${widget.rawScore}/10"),
            pw.Text("Grade: ${_getGrade(widget.difficulty)}"),
            pw.SizedBox(height: 16),
            pw.Text("Motivational Message:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(getMotivationalMessage()),
            pw.SizedBox(height: 16),

            // Performance Summary
            if (records.isNotEmpty) ...[
              _buildPerformanceSummary(),
              pw.SizedBox(height: 16),
            ],

            // Personalized Suggestions
            pw.Text("Personalized Suggestions:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            for (var suggestion in personalizedSuggestions)
              pw.Text("- $suggestion"),
            pw.SizedBox(height: 16),

            // Previous Records
            pw.Text("Previous Records:",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            if (records.isNotEmpty) ...[
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Date',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Score',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Time',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(4),
                          child: pw.Text('Level',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  for (var record in records) ...[
                    pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(record['recorded_date'] != null
                                ? _formatDate(
                                    record['recorded_date'].toString())
                                : 'N/A')),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text('${record['score']}%')),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(record['time_taken'] != null
                                ? formatTime(record['time_taken'])
                                : 'N/A')),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(4),
                            child: pw.Text(record['difficulty'] != null
                                ? _getGrade(record['difficulty'])
                                : 'N/A')),
                      ],
                    ),
                  ],
                ],
              ),
            ] else ...[
              pw.Text("No previous records found."),
            ],
            if (comparison.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              pw.Text("Performance Comparison:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  "Score Change: ${comparison['score_change'] ?? 'N/A'} (${comparison['score_difference'] ?? 'N/A'}%)"),
              pw.Text(
                  "Time Taken Change: ${comparison['time_change'] ?? 'N/A'} (${comparison['time_difference'] ?? 'N/A'}s)"),
              pw.Text(
                  "Difficulty Level Change: ${comparison['difficulty_change'] ?? 'N/A'}"),
            ],
          ],
        ),
      ),
    );

    final pdfInMemory = await pdf.save();

    // Save the PDF to a file for sharing
    final directory = await getTemporaryDirectory();
    pdfFile = File('${directory.path}/vocabulary_results.pdf');
    await pdfFile!.writeAsBytes(pdfInMemory);

    setState(() {
      isLoading = false;
    });

    // Don't store the result, just call the method
    if (mounted) {
      await _openPDFFromMemory(pdfInMemory);
    }
  }
