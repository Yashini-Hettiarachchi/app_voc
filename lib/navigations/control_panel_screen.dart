import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlPanelScreen extends StatefulWidget {
  @override
  _ControlPanelScreenState createState() => _ControlPanelScreenState();
}

class _ControlPanelScreenState extends State<ControlPanelScreen> {
  int _differenceDifficulty = 1;
  int _puzzleDifficulty = 1;
  // int _changeIdentificationDifficulty = 1;
  int _prepositionDifficulty = 1;
  int _vocabularyDifficulty = 1;

  // Load stored difficulty values from shared preferences
  Future<void> _loadDifficulty() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _differenceDifficulty = (prefs.getInt('difference_difficulty') ?? 1).clamp(1, 5);
      _puzzleDifficulty = (prefs.getInt('puzzle_difficulty') ?? 1).clamp(1, 5);
      // _changeIdentificationDifficulty = (prefs.getInt('change_identification_difficulty') ?? 1).clamp(1, 5);
      _prepositionDifficulty = (prefs.getInt('preposition_difficulty') ?? 1).clamp(1, 5);
      _vocabularyDifficulty = (prefs.getInt('vocabulary_difficulty') ?? 1).clamp(1, 5);
    });
  }

  // Save difficulty values to shared preferences
  Future<void> _applyChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('difference_difficulty', _differenceDifficulty);
    await prefs.setInt('puzzle_difficulty', _puzzleDifficulty);
    await prefs.setInt('preposition_difficulty', _prepositionDifficulty);
    await prefs.setInt('vocabulary_difficulty', _vocabularyDifficulty);

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Changes applied successfully!")),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDifficulty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Panel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Difficulty for Difference Recognition
            _buildRangeInput(
              'Difference Recognition Difficulty',
              _differenceDifficulty,
                  (value) {
                setState(() {
                  _differenceDifficulty = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Difficulty for Puzzle
            _buildRangeInput(
              'Puzzle Difficulty',
              _puzzleDifficulty,
                  (value) {
                setState(() {
                  _puzzleDifficulty = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Difficulty for Preposition
            _buildRangeInput(
              'Preposition Difficulty',
              _prepositionDifficulty,
                  (value) {
                setState(() {
                  _prepositionDifficulty = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Difficulty for Vocabulary
            _buildRangeInput(
              'Vocabulary Difficulty',
              _vocabularyDifficulty,
                  (value) {
                setState(() {
                  _vocabularyDifficulty = value;
                });
              },
            ),
            const SizedBox(height: 30),
            // Apply Changes button
            ElevatedButton(
              onPressed: _applyChanges,
              child: const Text("Apply Changes"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeInput(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                min: 1,
                max: 5,
                value: value.toDouble(),
                divisions: 4,
                onChanged: (double newValue) {
                  onChanged(newValue.toInt());
                },
              ),
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
