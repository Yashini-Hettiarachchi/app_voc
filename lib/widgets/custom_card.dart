import 'package:chat_app/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomCard extends StatefulWidget {
  const CustomCard({super.key});

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  String name = "No Name";
  Future<void> _applyChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      name = (prefs.getString('full_name')??"No Name");
    });

  }

  @override
  void initState() {
    super.initState();
    _applyChanges();
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xff27a5c6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello $name',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF232426),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Click below to explore fun facts and more about our services!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF232426),
                      fontWeight: FontWeight.w300,
                      fontFamily: 'ABeeZee'
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: () {},
                    label: const Text("Know More"),
                    icon: const Icon(Icons.bolt),
                    style: ElevatedButton.styleFrom(foregroundColor: Styles.fontLight),
                  ),
                ],
              ),
            ),
            Image.asset('assets/icons/gift.png', width: 140,)
          ],
        ),
      ),
    );
  }
}
