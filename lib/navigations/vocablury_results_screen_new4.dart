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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff80ca84),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VocabularyLevelsScreen()));
        },
        child: const Icon(Icons.list),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/backgrounds/fb3f8dc3b3e13aebe66e9ae3df8362e9.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Vocabulary Activity Summary',
                        style: TextStyle(fontSize: 20, color: Colors.black)),
                    SizedBox(height: 4),
                    Text('Your activity Results',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Colors.black)),
                  ],
                ),
                titleSpacing: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xff80ca84),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.6),
                          blurRadius: 10,
                          spreadRadius: 2)
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xff80ca84),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.6),
                            blurRadius: 10,
                            spreadRadius: 2)
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        _logout();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: totalScore >= 60
                      ? Colors.green.shade100
                      : Colors.yellow.shade100,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text('Total Score: $totalScore %',
                              style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          const SizedBox(height: 16.0),
                          Text('Time Taken: ${formatTime(widget.timeTaken)}',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black54)),
                          const SizedBox(height: 8.0),
                          Text('Raw Score: ${widget.rawScore}/10',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black87)),
                          const SizedBox(height: 8.0),
                          Text('Grade: ${_getGrade(widget.difficulty)}',
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black87)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SuggestedActivitiesScreen(
                                    totalScore: totalScore),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lightbulb),
                          label: const Text("Helpful Tips 💡"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[200],
                            foregroundColor: Colors.purple[900],
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : _generateAndShowPDF,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.picture_as_pdf_outlined),
                          label: Text(
                              isLoading ? "Making your report..." : "Make a Cool Report 📊"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[200],
                            foregroundColor: Colors.blue[900],
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
