import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_control/app_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const platform = MethodChannel("com.example.myapp/apps");

  void _navigateToAppListScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AppListScreen()),
    );
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await platform.invokeMethod("openAccessibilitySettings");
    } on PlatformException catch (error) {
      debugPrint(
        "Erreur lors de l'ouverture des paramètres d'accessibilité : $error",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AppBlock"),
        actions: [IconButton(icon: Icon(Icons.settings), onPressed: () => {})],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white, // radius of the corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Blocage Rapide",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      padding: EdgeInsets.zero,
                      onPressed: () => _navigateToAppListScreen(context),
                    ),
                  ),
                  ElevatedButton(
                    child: Text("Ouvrir les paramètres d'accessibilité"),
                    onPressed: () {
                      _openAccessibilitySettings();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
