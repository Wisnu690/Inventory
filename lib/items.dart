import 'package:flutter/material.dart';

class Items extends StatelessWidget {
  const Items({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Items"),
      ),
      body: const Center(
        child: Text("Halaman Items"),
      ),
    );
  }
}