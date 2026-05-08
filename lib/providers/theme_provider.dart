import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _boxName = 'nutripump_settings';
  static const _key = 'themeMode';

  ThemeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    // The box is already open — main() calls Hive.openBox() before app starts.
    // Using the synchronous accessor eliminates the one-frame theme flash.
    final box = Hive.box(_boxName);
    final savedMode = box.get(_key, defaultValue: 'light');
    
    switch (savedMode) {
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
        state = ThemeMode.system;
        break;
      case 'light':
      default:
        state = ThemeMode.light;
        break;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final box = Hive.box(_boxName);
    String stringMode;
    switch (mode) {
      case ThemeMode.light:
        stringMode = 'light';
        break;
      case ThemeMode.dark:
        stringMode = 'dark';
        break;
      case ThemeMode.system:
        stringMode = 'system';
        break;
    }
    await box.put(_key, stringMode);
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setTheme(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      await setTheme(ThemeMode.system);
    } else {
      await setTheme(ThemeMode.light);
    }
  }
}
