import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AndroidBridge {
  // Le même identifiant que celui défini en Kotlin
  static const platform = MethodChannel("com.example.myapp/apps");

  // Méthode pour récupérer la liste des applications installées
  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      // La méthode invoquée doit renvoyer une liste (List<dynamic>) que l'on convertit en List<String>
      final List<Map<String, dynamic>> result = await platform.invokeMethod('getInstalledApps');
      // Conversion en List<String>
      return result.map((app) => Map<String, dynamic>.from(app)).toList();
    } on PlatformException catch (e) {
      debugPrint("Erreur lors de la récupération des apps: ${e.message}");
      return [];
    }
  }

  Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final Uint8List? icon = await platform.invokeMethod('getAppIcon', {"packageName": packageName});
      return icon;
    } on PlatformException catch (e) {
      debugPrint("Erreur: ${e.message}");
      return null;
    }
  }
}
