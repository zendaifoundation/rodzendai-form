import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('บริการรถรับ-ส่งผู้ป่วย')),
      body: Column(
        children: [
          Container(
            child: const Center(child: Text('Welcome to the Home Page!')),
          ),
        ],
      ),
    );
  }
}
