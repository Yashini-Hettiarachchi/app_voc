import 'package:flutter/material.dart';

class JigsawPuzzleScreen extends StatefulWidget {
  final String title;
  final String image;
  final int puzzleBlocks;

  const JigsawPuzzleScreen({
    Key? key,
    required this.title,
    required this.image,
    required this.puzzleBlocks,
  }) : super(key: key);

  @override
  _JigsawPuzzleScreenState createState() => _JigsawPuzzleScreenState();
}

class _JigsawPuzzleScreenState extends State<JigsawPuzzleScreen> {
  late List<Widget> puzzlePieces;
  late List<int> correctOrder;
  late List<int?> currentOrder;

  @override
  void initState() {
    super.initState();
    initializePuzzle();
  }

  void initializePuzzle() {
    final blocks = widget.puzzleBlocks;
    correctOrder = List.generate(blocks, (index) => index);
    currentOrder = List.generate(blocks, (index) => null);
    puzzlePieces = generatePuzzlePieces();
  }

  List<Widget> generatePuzzlePieces() {
    int blocks = widget.puzzleBlocks;
    int gridSize = (blocks / 2).ceil();

    Image image = Image.asset(widget.image);
    return List.generate(blocks, (index) {
      return Draggable<int>(
        data: index,
        feedback: buildPuzzlePiece(image, index, gridSize),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: buildPuzzlePiece(image, index, gridSize),
        ),
        child: buildPuzzlePiece(image, index, gridSize),
      );
    })..shuffle();
  }

  Widget buildPuzzlePiece(Image image, int index, int gridSize) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        image: DecorationImage(
          image: AssetImage(widget.image),
          fit: BoxFit.cover,
          alignment: Alignment(
            (index % gridSize) / gridSize,
            (index ~/ gridSize) / gridSize,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blocks = widget.puzzleBlocks;
    final gridSize = (blocks / 2).ceil();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridSize,
                childAspectRatio: 1,
              ),
              itemCount: blocks,
              itemBuilder: (context, index) {
                return DragTarget<int>(
                  onAccept: (data) {
                    setState(() {
                      currentOrder[index] = data;
                    });
                  },
                  builder: (context, candidateData, rejectedData) {
                    final pieceIndex = currentOrder[index];
                    return pieceIndex == null
                        ? Container(
                      color: Colors.grey[200],
                    )
                        : buildPuzzlePiece(Image.asset(widget.image), pieceIndex, gridSize);
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: checkSolution,
            child: Text('Check Solution'),
          ),
        ],
      ),
    );
  }

  void checkSolution() {
    if (currentOrder.every((index) => index != null) &&
        List.generate(widget.puzzleBlocks, (i) => i).every((i) => currentOrder[i] == i)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You solved the puzzle!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The puzzle is not solved correctly!')),
      );
    }
  }
}
