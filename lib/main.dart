import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/busca_page.dart';
import 'widgets/theme_actions.dart';

void main() => runApp(const PrevisaoApp());

class PrevisaoApp extends StatefulWidget {
  const PrevisaoApp({super.key});
  @override
  State<PrevisaoApp> createState() => _PrevisaoAppState();
}

class _PrevisaoAppState extends State<PrevisaoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  Future<void> _carregarTema() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _themeMode = prefs.getBool('modo_escuro') == true ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> _alternarTema() async {
    final escuro = _themeMode != ThemeMode.dark;
    setState(() => _themeMode = escuro ? ThemeMode.dark : ThemeMode.light);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('modo_escuro', escuro);
  }

  ThemeData _tema(Brightness brightness) {
    final escuro = brightness == Brightness.dark;
    final esquema = ColorScheme.fromSeed(
      seedColor: const Color(0xff087f8c),
      brightness: brightness,
      surface: escuro ? const Color(0xff1c1c1e) : Colors.white,
    ).copyWith(
      primaryContainer: escuro ? const Color(0xff2b2b2f) : null,
      onPrimaryContainer: escuro ? const Color(0xffb8e5e2) : null,
      secondaryContainer: escuro ? const Color(0xff2b2b2f) : null,
      onSecondaryContainer: escuro ? const Color(0xfff2f2f7) : null,
      outlineVariant: escuro ? const Color(0xff38383a) : null,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: escuro ? const Color(0xff0b0b0d) : const Color(0xfff4f7f8),
      appBarTheme: AppBarTheme(
        backgroundColor: escuro ? const Color(0xff0b0b0d) : const Color(0xfff4f7f8),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: esquema.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: esquema.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: esquema.primary, width: 1.5)),
      ),
      cardTheme: CardThemeData(color: esquema.surface, surfaceTintColor: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Clima por aí',
        debugShowCheckedModeBanner: false,
        theme: _tema(Brightness.light),
        darkTheme: _tema(Brightness.dark),
        themeMode: _themeMode,
        builder: (context, child) => ThemeActions(onToggle: _alternarTema, child: child ?? const SizedBox.shrink()),
        home: const BuscaPage(),
      );
}
