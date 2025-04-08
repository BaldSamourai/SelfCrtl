import 'package:flutter/material.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> {
  // Liste mockée d'applications (remplacée plus tard par des données réelles)
  List<String> _allApps = [
    "Instagram",
    "Facebook",
    "TikTok",
    "Gmail",
    "Spotify",
  ];
  List<String> _filteredApps = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredApps = _allApps;
    _searchController.addListener(_filterApps);
  }

  // Filtrage des apps en temps réel [[2]][[5]]
  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApps =
          _allApps.where((app) => app.toLowerCase().contains(query)).toList();
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
        itemBuilder:
            (context, index) => ListTile(
              title: Text(_filteredApps[index]),
              leading: const Icon(Icons.apps),
              trailing: Checkbox(
                value: false, // À connecter à la logique de sélection
                onChanged: (value) {}, // À implémenter
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
