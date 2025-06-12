import 'package:demo/main.dart';
import 'package:flutter/material.dart';

class BrightnessToggle extends StatelessWidget {
  const BrightnessToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeMode,
      builder:
          (context, value, child) => IconButton(
            onPressed: () {
              themeMode.value =
                  value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
            },
            icon: Icon(
              value == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
    );
  }
}
