import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:self_control/model/app_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:self_control/services/android_bridge.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  static const platform = MethodChannel("com.example.myapp/apps");
  List<AppInfo> apps = [];
  List<AppInfo> filteredApps = [];

  // Dictionnaire pour stocker le cache des icônes (clé = package)
  Map<String, Uint8List?> iconCache = {};

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<String> blockedApps = [];

  //Debounce champs de texte pour éviter la recherche direct après la saisie
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _getInstalledApps();
    // _searchController.addListener(_filterApps);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Si un Timer est déjà en cours, on l'annule.
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Démarre un nouveau Timer qui exécute le filtrage au bout de 300ms.
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterApps();
    });
  }

  List<AppInfo> _getSelectedApps(List<AppInfo> apps) {
    return apps.where((app) => app.isChecked).toList();
  }

  Future<void> _saveBlockedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final blockedApps =
          apps.where((app) => app.isChecked).map((app) => app.package).toList();
      await prefs.setStringList('blockedApps', blockedApps);
    } catch (e) {}
  }

  Future<void> _loadBlockedApps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedBlockedApps = prefs.getStringList('blockedApps') ?? [];
      setState(() {
        for (var app in apps) {
          //Met à true s'il trouve l'app dans la liste
          app.isChecked = storedBlockedApps.contains(app.package);
        }
      });
    } catch (e) {}
  }

  Future<void> _getInstalledApps() async {
    try {
      final List result = await platform.invokeMethod(
        'getInstalledAppsWithoutIcon',
      );
      List<AppInfo> loadedApps = [];

      for (var app in result) {
        loadedApps.add(AppInfo(name: app['name'], package: app['package']));
      }

      setState(() {
        apps = loadedApps;
        filteredApps = apps;
      });
      _loadBlockedApps();
      _preloadIcons(); // Précharger les icônes dès que la liste est chargée
    } on PlatformException catch (e) {
      debugPrint("Failed to get apps: ${e.message}");
    }
  }

  // Précharge toutes les icônes et stocke-les dans iconCache
  Future<void> _preloadIcons() async {
    for (AppInfo app in apps) {
      _loadAppIcon(app.package).then((iconBytes) {
        if (mounted) {
          setState(() {
            iconCache[app.package] = iconBytes;
          });
        }
      });
    }
  }

  // Récupération de l'icône pour un package
  Future<Uint8List?> _loadAppIcon(String packageName) async {
    try {
      final Uint8List icon = await platform.invokeMethod("getAppIcon", {
        "packageName": packageName,
      });
      return icon;
    } on PlatformException catch (e) {
      debugPrint("Failed to load icon for package $packageName: ${e.message}");
      return null; // Retourne null si l'icône échoue à se charger
    }
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredApps =
          apps.where((app) => app.name.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher...',
                    hintStyle: TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(color: Colors.black87),
                )
                : Text(""),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  filteredApps = apps;
                  _searchController.clear();
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Text('Applications installées', textAlign: TextAlign.start),
        ),
      ),
      body:
          apps.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  Widget leadingWidget;
                  if (iconCache.containsKey(app.package)) {
                    if (iconCache[app.package] != null) {
                      leadingWidget = Image.memory(
                        iconCache[app.package]!,
                        width: 40,
                        height: 40,
                      );
                    } else {
                      // En cas d'erreur lors du chargement, affiche une icône par défaut
                      leadingWidget = const Icon(
                        Icons.image_not_supported,
                        size: 40,
                      );
                    }
                  } else {
                    // Si l'icône n'est pas encore chargée, affiche un indicateur de chargement local
                    leadingWidget = const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  }
                  return ListTile(
                    title: Text(app.name),
                    subtitle: Text(app.package),
                    leading: leadingWidget,
                    trailing: Checkbox(
                      value: app.isChecked,
                      onChanged:
                          (bool? value) => {
                            setState(() {
                              app.isChecked = value ?? false;
                            }),
                            debugPrint(
                              "list application bloquées > $_getSelectedApps",
                            ),
                            _saveBlockedApps(),
                          },
                    ),
                  );
                },
              ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
