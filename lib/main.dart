import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/timer_screen.dart';

void main() {
  runApp(const PitchTimerApp());
}

class PitchTimerApp extends StatelessWidget {
  const PitchTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pitch Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const TimerScreen(),
    );
  }
}
