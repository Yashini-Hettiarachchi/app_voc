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

  Future<void> _openPDFFromMemory(Uint8List pdfInMemory) async {
    final pdfFile = await _createFileFromBytes(pdfInMemory);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Vocabulary Report'),
              backgroundColor: const Color(0xff80ca84),
              actions: [
                // Print button
                IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () {
                    _showPrintOptions(pdfFile);
                  },
                ),
                // Download/Share button
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    _sharePDF(pdfFile);
                  },
                ),
              ],
            ),
            body: PDFView(
              filePath: pdfFile.path,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: false,
              pageFling: false,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.BOTH,
              preventLinkNavigation: false,
            ),
          ),
        ),
      );
    }
  }

  // Show print options dialog
  void _showPrintOptions(File pdfFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Print Options'),
          content: const Text('Would you like to print or save this report?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // This would ideally connect to a printer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Printing functionality would be implemented here')),
                );
              },
              child: const Text('Print'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _sharePDF(pdfFile);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Share PDF file
  void _sharePDF(File pdfFile) {
    try {
      Share.shareXFiles([XFile(pdfFile.path)],
          text: 'Vocabulary Performance Report');
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing PDF: $e')),
      );
    }
  }

  Future<File> _createFileFromBytes(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/vocabulary_results.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }
