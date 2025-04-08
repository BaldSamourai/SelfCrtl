import 'package:flutter/material.dart';
import 'package:self_control/home_screen.dart';

void main() {
  runApp(AppBlocker());
}

class AppBlocker extends StatelessWidget {
  const AppBlocker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AppBlock',
      theme: ThemeData(
        primaryColor: Colors.teal, // Définit la couleur principale de l'application
        scaffoldBackgroundColor: Colors.blueGrey[50], // Fond uniforme pour tout le Scaffold
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFECEFF1),
          elevation: 0, // Supprime l'ombre
        ),
      ),
      home: HomeScreen(),
    );
  }
}
