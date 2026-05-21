import 'package:flutter/material.dart';
import 'app/filmes/pages/filme_page.dart';
import 'app/shared/theme/theme.dart';

void main() {
  runApp(const UlbraFilmesApp());
}

class UlbraFilmesApp extends StatelessWidget {
  const UlbraFilmesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ULBRA Filmes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const FilmesPage(),
    );
  }
}