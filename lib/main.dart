import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/shared/theme/theme.dart';
import 'firebase_options.dart';
import 'screens/cadastro_screen.dart';
import 'screens/filmes_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseConfigurado = true;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    firebaseConfigurado = false;
  }
  runApp(UlbraFilmesApp(firebaseConfigurado: firebaseConfigurado));
}

class UlbraFilmesApp extends StatelessWidget {
  const UlbraFilmesApp({required this.firebaseConfigurado, super.key});

  final bool firebaseConfigurado;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ULBRA Filmes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: firebaseConfigurado && FirebaseAuth.instance.currentUser != null
          ? '/filmes'
          : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/cadastro': (_) => const CadastroScreen(),
        '/filmes': (_) => const FilmesScreen(),
      },
    );
  }
}
