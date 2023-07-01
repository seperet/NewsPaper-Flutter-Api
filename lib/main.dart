import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MaterialColor customColor = MaterialColor(
      0xFF0B090E,
      <int, Color>{
        50: Color.fromARGB(255, 43, 43, 44),
        100: Color.fromARGB(255, 43, 43, 44),
        200: Color.fromARGB(255, 43, 43, 44),
        300: Color.fromARGB(255, 43, 43, 44),
        400: Color.fromARGB(255, 43, 43, 44),
        500: Color.fromARGB(255, 43, 43, 44),
        600: Color.fromARGB(255, 43, 43, 44),
        700: Color.fromARGB(255, 43, 43, 44),
        800: Color.fromARGB(255, 43, 43, 44),
        900: Color.fromARGB(255, 43, 43, 44),
      },
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(
        primarySwatch: customColor,
      ),
    );
  }
}
