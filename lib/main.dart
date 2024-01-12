import 'package:flutter/material.dart';
import 'package:meditation_app/features/onboarding/screens/onboarding.dart';

Future<void> main() async {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigoAccent,
        ),
        useMaterial3: true,
      ),
      home: const OnBoardingScreen(),
    );
  }
}

