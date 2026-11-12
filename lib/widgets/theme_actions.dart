import 'package:flutter/material.dart';

class ThemeActions extends InheritedWidget {
  const ThemeActions({super.key, required this.onToggle, required super.child});
  final VoidCallback onToggle;

  static ThemeActions of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<ThemeActions>();
    assert(result != null, 'ThemeActions is missing above this context.');
    return result!;
  }

  @override
  bool updateShouldNotify(ThemeActions oldWidget) => onToggle != oldWidget.onToggle;
}
