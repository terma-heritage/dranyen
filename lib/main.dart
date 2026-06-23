import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/tuner_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const DramnyenTunerApp());
}

class DramnyenTunerApp extends StatelessWidget {
  const DramnyenTunerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dramnyen Tuner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A853),
          brightness: Brightness.dark,
        ),
      ),
      home: const TunerScreen(),
    );
  }
}
