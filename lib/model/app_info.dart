import 'dart:typed_data';

class AppInfo {
  final String name;
  final String package;
  Uint8List? icon; // Lazy-loaded

  AppInfo({
    required this.name,
    required this.package,
    this.icon,
  });

  AppInfo copyWith({Uint8List? icon}) {
    return AppInfo(name: name, package: package, icon: icon);
  }
}
