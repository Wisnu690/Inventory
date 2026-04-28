import 'package:flutter/material.dart';
import 'mainpage.dart'; // pastikan ini ada

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  void _startSplash() async {
    await Future.delayed(const Duration(seconds: 3));

    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => const MainPage()),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/images/Logo.png',
          width: 150,
        ),
      ),
    );
  }
}