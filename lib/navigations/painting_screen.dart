import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PaintingScreen extends StatefulWidget {
  @override
  _PaintingScreenState createState() => _PaintingScreenState();
}

class _PaintingScreenState extends State<PaintingScreen> {
  List<Offset?> points = []; // List to store points drawn by the user
  GlobalKey _canvasKey = GlobalKey();

  // Function to save the canvas as an image
  Future<void> saveCanvas() async {
    try {
      // RenderRepaintBoundary boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      // ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      // Uint8List pngBytes = byteData!.buffer.asUint8List();
      //
      // // Get directory to save the image
      // final directory = await getApplicationDocumentsDirectory();
      // final file = File('${directory.path}/painting_${DateTime.now()}.png');
      // await file.writeAsBytes(pngBytes);
      //
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Painting saved to ${file.path}')),
      // );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save painting')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Painting Canvas'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: RepaintBoundary(
          key: _canvasKey,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                points.add(details.localPosition); // Add each touch point
              });
            },
            onPanEnd: (details) {
              points.add(null); // Add a null point to separate strokes
            },
            child: CustomPaint(
              painter: CanvasPainter(points),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveCanvas,
        child: Icon(Icons.save),
        backgroundColor: Colors.purple,
      ),
    );
  }
}

class CanvasPainter extends CustomPainter {
  final List<Offset?> points;
  CanvasPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    // Draw lines between points
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) => oldDelegate.points != points;
}
