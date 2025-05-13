import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';

class IdeaCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget navigationWindow;

  const IdeaCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.navigationWindow,
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
      color: Styles.fontDark,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Styles.secondaryAccent.withOpacity(0.4), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _navigate(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Styles.fontLight, size: 30),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
