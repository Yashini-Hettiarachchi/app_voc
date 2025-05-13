import 'package:flutter/material.dart';

Color primary = Color(0xFF202021);

class Styles {
  static Color primaryColor = primary;
  static Color primaryAccent = const Color(0xFFFCE6F6);
  static Color secondaryColor = const Color(0xFFFF5CD3);
  static Color secondaryAccent = const Color(0xff27a5c6);
  static Color bgColor = const Color(0xFFF5F5F5);
  static Color warningColor = const Color(0xFFF0932B);
  static Color dangerColor = const Color(0xFFEB4D4B);
  static Color successColor = const Color(0xFF2ECC71);
  static Color infoColor = const Color(0xFF0687CC);
  // static Color fontColor = const Color(0xFF10161C);
  static Color fontLight = const Color(0xFFD4D4D4);
  static Color fontDark = const Color(0xFF171719);
  static Color fontHighlight = const Color(0xFF344FFA);
  static Color fontHighlight2 = const Color(0xFF2B2B2B);
  static Color shadowColor = const Color(0xFF2C2C2C);

//   Font Styles
  static TextStyle defaultLightFont = TextStyle(fontSize: 14, color: fontLight);
  static TextStyle defaultDarkFont = TextStyle(fontSize: 14, color: fontLight);
  static TextStyle titleLightFont = TextStyle(fontSize: 18, color: fontLight, fontWeight: FontWeight.bold);
  static TextStyle titleDarkFont = TextStyle(fontSize: 18, color: fontDark, fontWeight: FontWeight.bold);
  static TextStyle subTitleLightFont = TextStyle(fontSize: 16, color: fontLight, fontWeight: FontWeight.w300);
  static TextStyle subTitleDarkFont = TextStyle(fontSize: 16, color: fontDark, fontWeight: FontWeight.w300);
}
