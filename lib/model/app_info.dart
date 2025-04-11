import 'dart:typed_data';

class AppInfo {
  final String name;
  final String package;
  bool isChecked;
  Uint8List? icon; // Lazy-loaded

  AppInfo({
    required this.name,
    required this.package,
    this.icon,
    this.isChecked = false,
  });

  AppInfo copyWith({Uint8List? icon, bool? isChecked}) {
    return AppInfo(
      name: name,
      package: package,
      icon: icon ?? this.icon,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
