  void _useMockData() {
    setState(() {
      // Create mock records for demonstration
      records = [
        {
          'recorded_date': DateTime.now()
              .subtract(const Duration(days: 7))
              .toIso8601String(),
          'score': totalScore - 5,
          'time_taken': widget.timeTaken + 30,
          'difficulty':
              widget.difficulty > 1 ? widget.difficulty - 1 : widget.difficulty,
        },
        {
          'recorded_date': DateTime.now()
              .subtract(const Duration(days: 14))
              .toIso8601String(),
          'score': totalScore - 10,
          'time_taken': widget.timeTaken + 60,
          'difficulty':
              widget.difficulty > 1 ? widget.difficulty - 1 : widget.difficulty,
        },
        {
          'recorded_date': DateTime.now()
              .subtract(const Duration(days: 21))
              .toIso8601String(),
          'score': totalScore - 15,
          'time_taken': widget.timeTaken + 90,
          'difficulty':
              widget.difficulty > 1 ? widget.difficulty - 1 : widget.difficulty,
        }
      ];

      // Create mock comparison data
      comparison = {
        'score_change': 'Improved',
        'score_difference': 5,
        'time_change': 'Faster',
        'time_difference': 30,
        'difficulty_change': 'Increased',
      };

      // Generate score points for chart
      scorePoints = _generateScorePoints(records);

      isLoading = false;
    });

    // Generate personalized suggestions
    _generatePersonalizedSuggestions();
  }

  Future<void> _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('accessTokenExpireDate');
      await prefs.remove('refreshTokenExpireDate');
      await prefs.remove('userRole');
      await prefs.remove('authEmployeeID');
      await prefs.remove("vocabulary_difficulty");
      await prefs.remove("difference_difficulty");

      // Check if widget is still mounted before using context
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
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
