import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final kColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: const Color(0xfff55951),
  background: const Color(0xff5e5e5e),
  onBackground: const Color(0xff2b2b2b),
  surface: const Color(0xffffffff),
  onSurface: const Color(0xff5e5e5e),
);

final kTheme = ThemeData().copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: kColorScheme.background,
    colorScheme: kColorScheme,
    textTheme: GoogleFonts.bitterTextTheme().copyWith(
      titleSmall: GoogleFonts.dosis(
        fontWeight: FontWeight.bold,
      ),
      titleMedium: GoogleFonts.dosis(
        fontWeight: FontWeight.bold,
      ),
      titleLarge: GoogleFonts.dosis(
        fontWeight: FontWeight.bold,
      ),
    ));

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodToGo - Merchants',
      theme: kTheme,
      home: Text('Getting location...'),
    );
  }
}
