import 'package:flutter/material.dart';

import 'layouts/layouts.dart';

void main() {
  runApp(const BlueprintMaster());
}

class BlueprintMaster extends StatelessWidget {
  const BlueprintMaster({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(brightness: Brightness.light, useMaterial3: true, colorScheme: ColorScheme.light());
    return MaterialApp(title: "Blueprint Master", themeMode: ThemeMode.system, theme: theme, home: Scaffold(body: const Layout()));
  }
}
