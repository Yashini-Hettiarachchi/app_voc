import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AnswerCanvasScreen extends StatefulWidget {
  final Map<String, dynamic> question;

  AnswerCanvasScreen({required this.question});

  @override
  _AnswerCanvasScreenState createState() => _AnswerCanvasScreenState();
}

class _AnswerCanvasScreenState extends State<AnswerCanvasScreen> {
  List<Offset?> points = [];
  Color selectedColor = Colors.black;
  double brushSize = 5.0;
  bool isErasing = false;

  void _addPointFromStart(DragStartDetails details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    setState(() {
      points.add(renderBox.globalToLocal(details.globalPosition));
    });
  }

  void _addPoint(DragUpdateDetails details) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    setState(() {
      points.add(renderBox.globalToLocal(details.globalPosition));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Answer Canvas"),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                points.clear(); // Clear all points
              });
            },
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: _addPointFromStart,
        onPanUpdate: _addPoint,
        onPanEnd: (details) {
          setState(() {
            points.add(null); // Add a null point to separate lines
          });
        },
        child: CustomPaint(
          painter: MyPainter(points, selectedColor, brushSize, isErasing),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context); // Go back to the VocabularyScreen
        },
        child: Icon(Icons.check),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.color_lens, color: selectedColor),
                onPressed: () async {
                  Color? pickedColor = await showDialog(
                    context: context,
                    builder: (context) => ColorPickerDialog(
                      selectedColor: selectedColor,
                    ),
                  );
                  if (pickedColor != null) {
                    setState(() {
                      selectedColor = pickedColor;
                      isErasing = false; // Turn off erasing when selecting color
                    });
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.brush),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => BrushSizeDialog(
                      initialSize: brushSize,
                      onSizeSelected: (size) {
                        setState(() {
                          brushSize = size;
                          isErasing = false; // Turn off erasing when adjusting brush
                        });
                      },
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () {
                  setState(() {
                    isErasing = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;
  final double strokeWidth;
  final bool isErasing;

  MyPainter(this.points, this.color, this.strokeWidth, this.isErasing);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = isErasing ? Colors.white : color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.isErasing != isErasing;
  }
}

class ColorPickerDialog extends StatelessWidget {
  final Color selectedColor;

  ColorPickerDialog({required this.selectedColor});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Color"),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            Navigator.of(context).pop(color);
          },
        ),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class BrushSizeDialog extends StatelessWidget {
  final double initialSize;
  final ValueChanged<double> onSizeSelected;

  BrushSizeDialog({required this.initialSize, required this.onSizeSelected});

  @override
  Widget build(BuildContext context) {
    double selectedSize = initialSize;
    return AlertDialog(
      title: Text("Brush Size"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: selectedSize,
            min: 1.0,
            max: 20.0,
            onChanged: (size) {
              selectedSize = size;
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text("Apply"),
          onPressed: () {
            onSizeSelected(selectedSize);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}