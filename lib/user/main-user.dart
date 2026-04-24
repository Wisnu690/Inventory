import 'package:flutter/material.dart';
// UBAH BARIS INI: Hapus "package:saka_inventory/" dan biarkan nama filenya saja
import 'package:inventory/mainpage.dart'; 

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
    );
  }
}