import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_control/model/app_info.dart';
import 'package:self_control/services/android_bridge.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  static const platform = MethodChannel("com.example.myapp/apps");
  List<AppInfo> apps = [];

  @override
  void initState() {
    super.initState();
    _getInstalledApps();
  }

  Future<void> _getInstalledApps() async {
    try {
      final List result = await platform.invokeMethod('getInstalledAppsWithoutIcon');
      List<AppInfo> loadedApps = [];

      for (var app in result) {
        loadedApps.add(
          AppInfo(
            name: app['name'],
            package: app['package'],
            // icon: Uint8List.fromList(List<int>.from(app['icon'])),
            // icon: _loadIconAsync(app['icon']),
          ),
        );
      }

      setState(() {
        apps = loadedApps;
      });

      // Charger les icônes après coup
      for (var app in loadedApps) {
        _loadAppIcon(app);
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get apps: ${e.message}");
    }
  }

  Future<void> _loadAppIcon(AppInfo app) async {
    final Uint8List icon = await platform.invokeMethod("getAppIcon", {
      "packageName": app.package,
    });
    setState(() {
      app.icon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Applications installées')),
      body:
          apps.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return ListTile(
                  title: Text(app.name),
                  subtitle: Text(app.package),
                  leading: app.icon == null
                      ? const Icon(Icons.image_not_supported, size: 40) // Icône par défaut
                      : Image.memory(app.icon!, width: 40, height: 40), // Icône réelle
                );
                },
              ),
    );
  }

  /* List<Map<String, dynamic>> _installedApps = [];
  List<Map<String, dynamic>> _filteredApps = [];
  final AndroidBridge _androidBridge = AndroidBridge();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedApps = {};
  final Map<String, Uint8List?> _iconsCache = {}; // Cache pour les icônes

  @override
  void initState() {
    super.initState();
    _fetchInstalledApps();
    _searchController.addListener(_filterApps);
  }

  Future<void> _fetchInstalledApps() async {
    try {
      final apps = await _androidBridge.getInstalledApps();
      setState(() {
        _installedApps = apps;
        _filteredApps = _installedApps;
      });
    } catch (e) {
      debugPrint("Erreur: $e");
    }
  }

  Future<Uint8List?> _getIcon(String packageName) async {
    if (_iconsCache.containsKey(packageName)) {
      return _iconsCache[packageName];
    }
    final icon = await _androidBridge.getAppIcon(packageName);
    setState(() {
      _iconsCache[packageName] = icon; // Ajouter au cache
    });
    return icon;
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApps = _installedApps
          .where((app) => app["name"].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Liste des applications à bloquer"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Rechercher une app",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredApps.length,
        itemBuilder: (context, index) {
          final app = _filteredApps[index];
          final isSelected = _selectedApps.contains(app["package"]);

          return FutureBuilder<Uint8List?>(
            future: _getIcon(app["package"]),
            builder: (context, snapshot) {
              final icon = snapshot.data;
              return ListTile(
                leading: icon != null
                    ? CircleAvatar(
                        backgroundImage: MemoryImage(icon),
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.apps), // Placeholder
                      ),
                title: Text(app["name"]),
                subtitle: Text(app["package"]),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedApps.add(app["package"]);
                      } else {
                        _selectedApps.remove(app["package"]);
                      }
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  } */
}
