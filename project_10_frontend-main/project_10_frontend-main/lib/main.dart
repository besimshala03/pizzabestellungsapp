import 'package:flutter/material.dart';
import 'package:project_10_frontend/backend/backend.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:project_10_frontend/screen/main_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Definieren Sie Ihre Routen hier
      routes: {
        '/main_page': (context) => MainPage(Backend(), http.Client()),
      },
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 1), () {
      // Navigieren Sie zur MainPage über benannte Route
      Navigator.pushNamed(context, '/main_page');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/WhatsApp Image 2024-05-29 at 00.13.16.jpeg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
