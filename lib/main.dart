import 'package:flutter/material.dart';
import 'pages/busca_page.dart';

void main() => runApp(const PrevisaoApp());

class PrevisaoApp extends StatelessWidget {
  const PrevisaoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Clima por aí',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff087f8c),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xfff4f7f8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xfff4f7f8),
            surfaceTintColor: Colors.transparent,
            centerTitle: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xffe4eaec))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xff087f8c), width: 1.5)),
          ),
        ),
        home: const BuscaPage(),
      );
}
