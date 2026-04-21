import 'package:flutter/material.dart';

class User extends StatelessWidget {
  const User({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User"),
      ),
      body: const Center(
        child: Text("Halaman User"),
      ),
    );
  }
} 