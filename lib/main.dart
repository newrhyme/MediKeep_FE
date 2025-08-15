import 'package:flutter/material.dart';
import 'screens/start_page.dart';

void main() {
  runApp(const MediKeepApp());
}

class MediKeepApp extends StatelessWidget {
  const MediKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediKeep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const StartPage(),
    );
  }
}
