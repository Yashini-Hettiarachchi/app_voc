import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';

class LongCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget navigationWindow;
  final Color backgroundColor; // New parameter for background color

  const LongCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.navigationWindow,
    this.backgroundColor = Colors.white, // Default color if not provided
  }) : super(key: key);

  void _navigate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => navigationWindow),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor, // Use the passed background color
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Styles.secondaryAccent.withOpacity(0.4), width: 2),
        borderRadius: BorderRadius.circular(40),
      ),
      child: InkWell(
        onTap: () => _navigate(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Styles.fontHighlight2.withOpacity(0.5),
                size: 20,
              ),

              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,

                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, color: Color(0xFF94B7B1)),
            ],
          ),
        ),
      ),
    );
  }
}
