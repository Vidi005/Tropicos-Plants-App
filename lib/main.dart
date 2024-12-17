import 'package:flutter/material.dart';
import 'package:tropicos_plants_app/main_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(const TropicosPlantsApp());
}

class TropicosPlantsApp extends StatelessWidget {
  const TropicosPlantsApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Tropicos Plants App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      );
}
